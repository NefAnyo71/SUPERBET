import 'dart:math';
import 'package:flutter/material.dart';
import '../models/slot_symbol.dart';
import 'slot_reel.dart';

class SlotMachine extends StatelessWidget {
  final List<int> reels;
  final List<SlotSymbol> symbols;
  final bool spinning;
  final List<AnimationController> reelControllers;
  final AnimationController neonController;
  final Random rand;

  const SlotMachine({
    super.key,
    required this.reels,
    required this.symbols,
    required this.spinning,
    required this.reelControllers,
    required this.neonController,
    required this.rand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: neonController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.3),
                Colors.pink.withValues(alpha: 0.3),
                Colors.blue.withValues(alpha: 0.3),
              ],
              stops: [
                (neonController.value - 0.2).clamp(0.0, 1.0),
                neonController.value,
                (neonController.value + 0.2).clamp(0.0, 1.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2d1b69),
                  Color(0xFF11998e),
                  Color(0xFF38ef7d),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                return SlotReel(
                  reelIndex: reels[i],
                  symbols: symbols,
                  spinning: spinning,
                  controller: reelControllers[i],
                  rand: rand,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}