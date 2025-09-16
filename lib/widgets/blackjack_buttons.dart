import 'package:flutter/material.dart';
import 'neon_button.dart';

class BlackjackButtons extends StatelessWidget {
  final String gameStatus;
  final AnimationController pulseController;
  final VoidCallback? onDecreaseBet;
  final VoidCallback? onIncreaseBet;
  final VoidCallback? onStartGame;
  final VoidCallback? onHit;
  final VoidCallback? onStand;
  final VoidCallback? onNewGame;

  const BlackjackButtons({
    super.key,
    required this.gameStatus,
    required this.pulseController,
    this.onDecreaseBet,
    this.onIncreaseBet,
    this.onStartGame,
    this.onHit,
    this.onStand,
    this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    if (gameStatus == 'betting') {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NeonButton(
                onPressed: onDecreaseBet,
                color: Colors.red,
                pulseController: pulseController,
                child: const Icon(Icons.remove, color: Colors.white, size: 24),
              ),
              NeonButton(
                onPressed: onIncreaseBet,
                color: Colors.green,
                pulseController: pulseController,
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: onStartGame,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.9),
                        Colors.teal.withValues(alpha: 0.8),
                        Colors.green.withValues(alpha: 0.9),
                      ],
                      stops: [
                        (pulseController.value - 0.3).clamp(0.0, 1.0),
                        pulseController.value,
                        (pulseController.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🃏 OYUNA BAŞLA 🃏',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.green, blurRadius: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else if (gameStatus == 'playing') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(right: 8),
                child: NeonButton(
                  onPressed: onHit,
                  color: Colors.blue,
                  pulseController: pulseController,
                  child: const Text(
                    'HIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(left: 8),
                child: NeonButton(
                  onPressed: onStand,
                  color: Colors.orange,
                  pulseController: pulseController,
                  child: const Text(
                    'STAND',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (gameStatus == 'finished') {
      return AnimatedBuilder(
        animation: pulseController,
        builder: (context, child) {
          return GestureDetector(
            onTap: onNewGame,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.9),
                    Colors.indigo.withValues(alpha: 0.8),
                    Colors.purple.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.6),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🎲 YENİ OYUN 🎲',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.purple, blurRadius: 15),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    
    return const SizedBox.shrink();
  }
}