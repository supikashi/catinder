import 'package:flutter/material.dart';
import '../services/cat_queue_service.dart';
import '../widgets/cat_card.dart';
import '../widgets/swipe_action_buttons.dart';
import 'cat_details_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late CatQueueService _queueService;

  int _likeCounter = 0;
  bool _isReturningCard = false;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  Animation<Offset>? _animation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Offset _dragOffset = Offset.zero;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _queueService = CatQueueService();
    _queueService.addListener(_onQueueServiceUpdate);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _initializeQueue();
  }

  void _onQueueServiceUpdate() {
    if (_isReturningCard) return;

    setState(() {
      _dragOffset = Offset.zero;
      _animationController.reset();
    });
  }

  Future<void> _initializeQueue() async {
    try {
      await _queueService.initialize();
      if (mounted) {
        _fadeController.forward(from: 0.0);
      }
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    _queueService.removeListener(_onQueueServiceUpdate);
    _animationController.dispose();
    _fadeController.dispose();
    _queueService.dispose();
    super.dispose();
  }

  Future<void> _loadNextCat() async {
    try {
      await _queueService.getNextCat();
      if (mounted) {
        _dragOffset = Offset.zero;
        _animationController.reset();
        _fadeController.forward(from: 0.0);
      }
    } catch (e) {
      //
    }
  }

  Future<void> _retryCurrentCat() async {
    try {
      await _queueService.retry();
    } catch (e) {
      //
    }
  }

  Future<void> _triggerAction(bool isLike) async {
    final currentItem = _queueService.currentItem;
    if (currentItem is! CatLoaded || _animationController.isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isLike ? screenWidth * 1.5 : -screenWidth * 1.5;

    final startOffset =
        _dragOffset == Offset.zero ? Offset(isLike ? 50 : -50, 0) : _dragOffset;

    _animation = Tween<Offset>(
      begin: startOffset,
      end: Offset(targetX, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    setState(() => _dragOffset = startOffset);

    await _animationController.forward(from: 0);

    if (mounted) {
      _animationController.reset();
    }

    try {
      if (isLike) {
        setState(() => _likeCounter++);
      }
      await _loadNextCat();
    } catch (e) {
      if (mounted) {
        setState(() => _dragOffset = Offset(targetX, 0));

        _animation = Tween<Offset>(
          begin: Offset(targetX, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

        await _animationController.forward(from: 0.0);

        if (mounted) {
          setState(() {
            _dragOffset = Offset.zero;
            _animationController.reset();
          });
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += Offset(details.delta.dx, 0);
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    final currentItem = _queueService.currentItem;
    if (currentItem is! CatLoaded || _animationController.isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4;
    final velocity = details.primaryVelocity?.abs() ?? 0;

    if (_dragOffset.dx.abs() > threshold || velocity > 500.0) {
      await _triggerAction(_dragOffset.dx > 0);
    } else {
      _isReturningCard = true;
      final startOffset = _dragOffset;

      _animation = Tween<Offset>(
        begin: startOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      void updateDragOffset() {
        if (mounted && _animation != null) {
          setState(() {
            _dragOffset = _animation!.value;
          });
        }
      }

      _animationController.addListener(updateDragOffset);

      await _animationController.forward(from: 0.0);

      _animationController.removeListener(updateDragOffset);

      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
          _animationController.reset();
        });
      }
      _isReturningCard = false;
    }
  }

  void _onCardTap() {
    final currentItem = _queueService.currentItem;
    if (currentItem is! CatLoaded || _animationController.isAnimating) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatDetailsScreen(cat: currentItem.cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _queueService.setContext(context);

    final currentItem = _queueService.currentItem;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.5, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey(currentItem is CatLoaded
                        ? currentItem.cat.id
                        : 'empty'),
                    children: [
                      if (currentItem is CatLoaded &&
                          currentItem.cat.breed != null) ...[
                        Text(
                          currentItem.cat.breed!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentItem.cat.breed!.origin,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SwipeActionButtons(
                  onDislike: () => _triggerAction(false),
                  onLike: () => _triggerAction(true),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_likeCounter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final currentItem = _queueService.currentItem;

    return switch (currentItem) {
      CatError(message: final errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryCurrentCat,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      CatLoading() => CatCard(
          cat: null,
          isLoading: true,
          dragOffset: _dragOffset,
          animation: _animation,
          animationController: _animationController,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
          onTap: _onCardTap,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
      CatLoaded(cat: final cat) => CatCard(
          cat: cat,
          isLoading: false,
          dragOffset: _dragOffset,
          animation: _animation,
          animationController: _animationController,
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
          onTap: _onCardTap,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
    };
  }
}
