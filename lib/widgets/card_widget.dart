import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final Card? card;
  final bool isHidden;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    this.card,
    this.isHidden = false,
    this.width = 60,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isHidden ? Colors.blue.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: isHidden
          ? Center(
              child: Icon(
                Icons.casino,
                color: Colors.white,
                size: width * 0.4,
              ),
            )
          : card != null
              ? Center(
                  child: Text(
                    card!.display,
                    style: TextStyle(
                      fontSize: width * 0.25,
                      fontWeight: FontWeight.bold,
                      color: ['♥️', '♦️'].contains(card!.suit)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                )
              : const SizedBox(),
    );
  }
}