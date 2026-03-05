import 'package:flutter/material.dart';
import '../../domain/entities/cat.dart';
import '../../core/errors.dart';

class CatCard extends StatefulWidget {
  final Cat? cat;
  final bool isLoading;

  final Offset dragOffset;
  final Animation<Offset>? animation;
  final AnimationController animationController;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const CatCard({
    super.key,
    required this.cat,
    required this.isLoading,
    required this.dragOffset,
    this.animation,
    required this.animationController,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  State<CatCard> createState() => _CatCardState();
}

class _CatCardState extends State<CatCard> {
  Key _imageKey = UniqueKey();

  void _retryImage() {
    setState(() {
      _imageKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final isLoading = widget.isLoading;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cat == null) {
      return const Center(child: Text('Не удалось загрузить кота'));
    }

    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: widget.onPanStart,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [widget.animationController, widget.fadeAnimation]),
        builder: (context, child) {
          final position = widget.animationController.isAnimating
              ? (widget.animation?.value ?? widget.dragOffset)
              : widget.dragOffset;

          final screenWidth = MediaQuery.of(context).size.width;
          final rotationAngle = position.dx / (screenWidth / 2) * 0.4;

          return FadeTransition(
            opacity: widget.fadeAnimation,
            child: ScaleTransition(
              scale: widget.scaleAnimation,
              child: Transform.translate(
                offset: position,
                child: Transform.rotate(
                  angle: rotationAngle,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            color: Colors.grey[300],
            child: Image.network(
              cat.url,
              key: _imageKey,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: frame == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image,
                          size: 56, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(ErrorMessages.imageLoadError,
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _retryImage,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
