import 'package:flutter/material.dart';

class BlackjackBalance extends StatelessWidget {
  final int balance;
  final int bet;
  final String gameStatus;
  final AnimationController pulseController;
  final VoidCallback? onBetTap;

  const BlackjackBalance({
    super.key,
    required this.balance,
    required this.bet,
    required this.gameStatus,
    required this.pulseController,
    this.onBetTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B4513).withValues(alpha: 0.4),
                const Color(0xFFD2691E).withValues(alpha: 0.3),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(
                alpha: 0.7 + pulseController.value * 0.3,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(
                  alpha: 0.4 + pulseController.value * 0.3,
                ),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'BAKİYE',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$balance ₺',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Color(0xFFFFD700), blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: gameStatus == 'betting' ? onBetTap : null,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'BAHİS',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gameStatus == 'betting') ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.edit,
                            color: Colors.white70,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$bet ₺',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Color(0xFFFFD700), blurRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}