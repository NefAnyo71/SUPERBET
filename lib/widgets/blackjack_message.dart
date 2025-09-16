import 'package:flutter/material.dart';

class BlackjackMessage extends StatelessWidget {
  final String message;
  final String gameStatus;
  final AnimationController pulseController;

  const BlackjackMessage({
    super.key,
    required this.message,
    required this.gameStatus,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gameStatus == 'finished' && message.contains('Kazandınız')
                  ? [
                      Colors.green.withValues(alpha: 0.3),
                      Colors.lime.withValues(alpha: 0.2),
                    ]
                  : gameStatus == 'finished' && message.contains('BLACKJACK')
                      ? [
                          Colors.amber.withValues(alpha: 0.4),
                          Colors.orange.withValues(alpha: 0.3),
                        ]
                      : [
                          Colors.cyan.withValues(alpha: 0.3),
                          Colors.blue.withValues(alpha: 0.2),
                        ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.cyan.withValues(
                alpha: 0.5 + pulseController.value * 0.3,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: Colors.cyan, blurRadius: 10),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}