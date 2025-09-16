import 'package:flutter/material.dart';

class SpinButton extends StatelessWidget {
  final bool spinning;
  final VoidCallback? onPressed;
  final AnimationController pulseController;

  const SpinButton({
    super.key,
    required this.spinning,
    required this.onPressed,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: spinning ? null : onPressed,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: spinning
                  ? LinearGradient(
                      colors: [
                        Colors.grey.withValues(alpha: 0.5),
                        Colors.grey.withValues(alpha: 0.3),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.9),
                        Colors.pink.withValues(alpha: 0.8),
                        Colors.purple.withValues(alpha: 0.9),
                      ],
                      stops: [
                        (pulseController.value - 0.3).clamp(0.0, 1.0),
                        pulseController.value,
                        (pulseController.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: spinning
                    ? Colors.grey
                    : Colors.white.withValues(alpha: 0.8),
                width: 3,
              ),
              boxShadow: spinning
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
            ),
            child: Center(
              child: spinning
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SPINNING...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '🎰 MEGA SPIN 🎰',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.red.withValues(alpha: 0.8),
                            blurRadius: 15,
                          ),
                          Shadow(
                            color: Colors.pink.withValues(alpha: 0.6),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}