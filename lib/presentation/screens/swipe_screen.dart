import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cat_provider.dart';
import '../widgets/cat_card.dart';
import '../widgets/swipe_action_buttons.dart';
import 'cat_details_screen.dart';
import '../../domain/entities/cat.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Offset _dragOffset = Offset.zero;
  Animation<Offset>? _dragAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
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

  void _onPanEnd(DragEndDetails details, CatProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4;
    final velocity = details.primaryVelocity?.abs() ?? 0;

    if (_dragOffset.dx.abs() > threshold || velocity > 500.0) {
      _triggerSwipeAnimation(provider, _dragOffset.dx > 0);
    } else {
      _resetCardPosition();
    }
  }

  Future<void> _triggerSwipeAnimation(CatProvider provider, bool isLike) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isLike ? screenWidth * 1.5 : -screenWidth * 1.5;

    setState(() {
      _dragAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(targetX, 0),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
    });

    await _animationController.forward(from: 0);

    if (isLike) {
      provider.likeCat();
    } else {
      provider.dislikeCat();
    }

    _resetCardStateForNext();
  }

  Future<void> _triggerButtonAction(CatProvider provider, bool isLike) async {
    if (_animationController.isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isLike ? screenWidth * 1.5 : -screenWidth * 1.5;

    setState(() {
      _dragAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(targetX, 0),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
    });

    await _animationController.forward(from: 0);

    if (isLike) {
      provider.likeCat();
    } else {
      provider.dislikeCat();
    }

    _resetCardStateForNext();
  }

  void _resetCardPosition() {
    setState(() {
      _dragAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack),
      );
    });

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _dragAnimation = null;
      });
      _animationController.reset();
    });
  }

  void _resetCardStateForNext() {
    setState(() {
      _dragOffset = Offset.zero;
      _dragAnimation = null;
    });
    _animationController.reset();
    _fadeController.forward(from: 0.0);
  }

  void _openDetails(Cat cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatDetailsScreen(cat: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<CatProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        Cat? currentCat;
        bool isLoading = false;
        String? error;

        if (state is CatLoaded) {
          currentCat = state.currentCat;
        } else if (state is CatLoading) {
          isLoading = true;
        } else if (state is CatError) {
          error = state.message;
        }

        if (error != null) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(error),
                ElevatedButton(
                  onPressed: () => provider.initialize(),
                  child: const Text('Retry'),
                )
              ]));
        }

        return Stack(
          children: [
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (currentCat != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                bottom: 100,
                child: CatCard(
                  cat: currentCat,
                  isLoading: isLoading,
                  dragOffset: _dragOffset,
                  animation: _dragAnimation,
                  animationController: _animationController,
                  fadeAnimation: _fadeAnimation,
                  scaleAnimation: _scaleAnimation,
                  onTap: () => _openDetails(currentCat!),
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: (details) => _onPanEnd(details, provider),
                ),
              ),
            if (currentCat != null)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: SwipeActionButtons(
                  onDislike: () => _triggerButtonAction(provider, false),
                  onLike: () => _triggerButtonAction(provider, true),
                ),
              ),
          ],
        );
      },
    );
  }
}
