import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';

import 'card_animation.dart';

class BlackjackCards extends StatelessWidget {
  final List<Card> cards;
  final int score;
  final String title;
  final Color color;
  final IconData icon;
  final bool hideSecondCard;

  const BlackjackCards({
    super.key,
    required this.cards,
    required this.score,
    required this.title,
    required this.color,
    required this.icon,
    this.hideSecondCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513).withValues(alpha: 0.3),
            const Color(0xFFD2691E).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                  shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 8)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < cards.length; i++)
                  CardAnimation(
                    key: ValueKey('${title}_${i}_${cards[i].suit}_${cards[i].rank}'),
                    card: cards[i],
                    isDealer: title.contains('Dealer'),
                    index: i,
                    showCard: !(hideSecondCard && i == 1),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B4513).withValues(alpha: 0.4),
                  const Color(0xFFD2691E).withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hideSecondCard 
                  ? 'Skor: ${cards.isNotEmpty ? cards[0].value : '?'}'
                  : 'Skor: $score',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}