import 'package:flutter/material.dart';

class MessageArea extends StatelessWidget {
  final String message;
  final int winAmount;
  final AnimationController pulseController;

  const MessageArea({
    super.key,
    required this.message,
    required this.winAmount,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: winAmount > 0
                  ? [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ]
                  : [
                      Colors.purple.withValues(alpha: 0.3),
                      Colors.blue.withValues(alpha: 0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: winAmount > 0
                  ? Colors.amber.withValues(alpha: 0.7)
                  : Colors.cyan.withValues(
                      alpha: 0.5 + pulseController.value * 0.3,
                    ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: winAmount > 0
                    ? Colors.amber.withValues(alpha: 0.4)
                    : Colors.cyan.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: winAmount > 0 ? Colors.amber : Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: winAmount > 0 ? Colors.amber : Colors.cyan,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}