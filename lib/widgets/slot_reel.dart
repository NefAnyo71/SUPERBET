import 'dart:math';
import 'package:flutter/material.dart';
import '../models/slot_symbol.dart';

class SlotReel extends StatelessWidget {
  final int reelIndex;
  final List<SlotSymbol> symbols;
  final bool spinning;
  final AnimationController controller;
  final Random rand;

  const SlotReel({
    super.key,
    required this.reelIndex,
    required this.symbols,
    required this.spinning,
    required this.controller,
    required this.rand,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        height: 100,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.black87,
              Colors.black54,
              Colors.purple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: spinning
                ? Colors.amber.withValues(alpha: 0.8)
                : Colors.cyan.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: spinning
                  ? Colors.amber.withValues(alpha: 0.6)
                  : Colors.cyan.withValues(alpha: 0.4),
              blurRadius: spinning ? 20 : 10,
              spreadRadius: spinning ? 2 : 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 100,
            child: Center(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  if (spinning) {
                    final currentSymbol = (rand.nextInt(100) + controller.value * 100).round() % symbols.length;
                    return Text(
                      symbols[currentSymbol].emoji,
                      style: TextStyle(
                        fontSize: 45,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.white,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text(
                      symbols[reelIndex].emoji,
                      style: TextStyle(
                        fontSize: 45,
                        shadows: [
                          Shadow(
                            blurRadius: 20.0,
                            color: symbols[reelIndex].color,
                            offset: const Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 40.0,
                            color: symbols[reelIndex].color.withValues(alpha: 0.5),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}