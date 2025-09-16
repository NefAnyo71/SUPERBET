import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import 'slot_game.dart';
import 'blackjack_game.dart';

class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Merkezi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hangi oyunu oynamak istiyorsun?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GameCard(
              title: 'Slot Makinesi',
              description: 'Şansını dene ve jackpot kazan!',
              icon: Icons.casino,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SlotGame()),
                );
              },
            ),
            const SizedBox(height: 20),
            GameCard(
              title: 'BlackJack',
              description: '21\'e en yakın ol ve kazan!',
              icon: Icons.style,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BlackJackGame()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}