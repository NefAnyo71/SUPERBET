import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final AnimationController pulseController;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.color,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, _) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: onPressed != null
                  ? LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color.withValues(alpha: 0.6),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.withValues(alpha: 0.5),
                        Colors.grey.withValues(alpha: 0.3),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: onPressed != null
                    ? color.withValues(alpha: 0.8)
                    : Colors.grey,
                width: 2,
              ),
              boxShadow: onPressed != null
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: child,
          ),
        );
      },
    );
  }
}