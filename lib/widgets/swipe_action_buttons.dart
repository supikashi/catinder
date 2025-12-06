import 'package:flutter/material.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onDislike;
  final VoidCallback onLike;

  const SwipeActionButtons({
    super.key,
    required this.onDislike,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: onDislike,
          backgroundColor: Colors.red,
          heroTag: 'dislike',
          child: const Icon(Icons.close, color: Colors.white),
        ),
        FloatingActionButton(
          onPressed: onLike,
          backgroundColor: Colors.green,
          heroTag: 'like',
          child: const Icon(Icons.favorite, color: Colors.white),
        ),
      ],
    );
  }
}
