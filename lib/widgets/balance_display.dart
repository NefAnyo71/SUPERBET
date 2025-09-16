import 'package:flutter/material.dart';

class BalanceDisplay extends StatelessWidget {
  final int balance;
  final int winAmount;
  final AnimationController pulseController;

  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.winAmount,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.cyan.withValues(
                alpha: 0.5 + pulseController.value * 0.5,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(
                  alpha: 0.3 + pulseController.value * 0.4,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    'BAKIYE',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.cyan.withValues(alpha: 0.8),
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
                        Shadow(color: Colors.cyan, blurRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
              if (winAmount > 0)
                Column(
                  children: [
                    Text(
                      'KAZANÇ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$winAmount ₺',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        shadows: [
                          Shadow(color: Colors.amber, blurRadius: 15),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}