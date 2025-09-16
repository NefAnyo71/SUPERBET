import 'package:flutter/material.dart';

class BlackjackResultPopup extends StatelessWidget {
  final String result;
  final int winAmount;
  final int bet;

  const BlackjackResultPopup({
    super.key,
    required this.result,
    required this.winAmount,
    required this.bet,
  });

  static void show(BuildContext context, {
    required String result,
    required int winAmount,
    required int bet,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlackjackResultPopup(
        result: result,
        winAmount: winAmount,
        bet: bet,
      ),
    );
    
    // 3 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWin = result == 'blackjack' || result == 'won';
    final isBlackjack = result == 'blackjack';
    final isPush = result == 'push';
    
    Color backgroundColor;
    Color accentColor;
    String title;
    String emoji;
    
    if (isBlackjack) {
      backgroundColor = const Color(0xFFFFD700); // Altın
      accentColor = const Color(0xFFFFA500);
      title = 'BLACKJACK!';
      emoji = '🎰';
    } else if (isWin) {
      backgroundColor = Colors.green.shade800;
      accentColor = Colors.green.shade600;
      title = 'KAZANDINIZ!';
      emoji = '🎉';
    } else if (isPush) {
      backgroundColor = Colors.blue.shade800;
      accentColor = Colors.blue.shade600;
      title = 'BERABERE!';
      emoji = '🤝';
    } else {
      backgroundColor = Colors.red.shade800;
      accentColor = Colors.red.shade600;
      title = 'KAYBETTİNİZ!';
      emoji = '😞';
    }

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: accentColor, width: 4),
      ),
      title: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 50),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isWin || isPush) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    isBlackjack ? 'BLACKJACK BONUSU!' : isPush ? 'BAHIS İADE' : 'KAZANÇ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '+$winAmount ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bahis:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$bet ₺',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isWin || isPush) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '+$winAmount ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),

    );
  }
}