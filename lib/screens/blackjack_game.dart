import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import '../models/card.dart';
import '../services/blackjack_logic.dart';
import '../services/winrate_algorithm.dart';
import '../services/storage_service.dart';
import '../widgets/blackjack_balance.dart';
import '../widgets/blackjack_cards.dart';
import '../widgets/blackjack_message.dart';
import '../widgets/blackjack_buttons.dart';
import '../widgets/bonus_popup.dart';
import '../widgets/blackjack_result_popup.dart';

class BlackJackGame extends StatefulWidget {
  const BlackJackGame({super.key});

  @override
  State<BlackJackGame> createState() => _BlackJackGameState();
}

class _BlackJackGameState extends State<BlackJackGame> with TickerProviderStateMixin {
  List<Card> _deck = [];
  List<Card> _playerCards = [];
  List<Card> _dealerCards = [];
  int _balance = 1000;
  int _initialBalance = 1000;
  int _bet = 10;
  int _playerScore = 0;
  int _dealerScore = 0;
  String _gameStatus = 'betting';
  String _message = 'Bahis yapın ve oyuna başlayın!';
  bool _showDealerCard = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final data = await StorageService.loadGameData();
    setState(() {
      _balance = data['balance'];
      _initialBalance = data['initialBalance'] ?? 1000;
    });
  }

  Future<void> _saveGameData() async {
    await StorageService.saveGameData(
      balance: _balance,
      initialBalance: _initialBalance,
      totalBets: 0,
      totalWins: 0,
      gamesPlayed: 0,
      gameHistory: [],
    );
  }

  void _startNewGame() {
    if (_balance < _bet) {
      setState(() => _message = 'Bakiye yetersiz!');
      return;
    }

    setState(() {
      _deck = BlackJackLogic.createDeck();
      _playerCards = [];
      _dealerCards = [];
      _balance -= _bet;
      _gameStatus = 'playing';
      _showDealerCard = false;
      _message = 'Kartlarınız dağıtılıyor...';
    });

    _dealInitialCards();
  }

  void _dealInitialCards() {
    setState(() {
      _playerCards.add(_deck.removeLast());
      _dealerCards.add(_deck.removeLast());
      _playerCards.add(_deck.removeLast());
      _dealerCards.add(_deck.removeLast());
      
      _playerScore = BlackJackLogic.calculateScore(_playerCards);
      _dealerScore = BlackJackLogic.calculateScore(_dealerCards);
      
      if (_playerScore == 21) {
        _message = 'BLACKJACK! 🎉';
        _endGame();
      } else {
        _message = 'Hit veya Stand seçin';
      }
    });
  }

  void _hit() {
    if (_gameStatus != 'playing') return;

    setState(() {
      _playerCards.add(_deck.removeLast());
      _playerScore = BlackJackLogic.calculateScore(_playerCards);
      
      if (_playerScore > 21) {
        _message = 'Bust! Kaybettiniz 😞';
        _endGame();
      } else if (_playerScore == 21) {
        _message = '21! Mükemmel 🎯';
        _stand();
      } else {
        _message = 'Hit veya Stand seçin';
      }
    });

    HapticFeedback.lightImpact();
  }

  void _stand() {
    if (_gameStatus != 'playing') return;

    setState(() {
      _gameStatus = 'dealer';
      _showDealerCard = true;
      _message = 'Dealer kartlarını çekiyor...';
    });

    _dealerPlay();
  }

  void _dealerPlay() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final shouldPlayerWin = WinrateAlgorithm.shouldPlayerWin('blackjack', _balance + _bet, _initialBalance, _bet);
    
    // Dealer 17 veya üstünde durmalı
    while (_dealerScore < 17) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (shouldPlayerWin && _dealerScore >= 15 && _dealerScore <= 16) {
        final bustCard = _deck.firstWhere((card) => card.value + _dealerScore > 21, orElse: () => _deck.last);
        _deck.remove(bustCard);
        setState(() {
          _dealerCards.add(bustCard);
          _dealerScore = BlackJackLogic.calculateScore(_dealerCards);
        });
        break;
      } else {
        setState(() {
          _dealerCards.add(_deck.removeLast());
          _dealerScore = BlackJackLogic.calculateScore(_dealerCards);
        });
      }
    }

    _endGame();
  }

  void _endGame() {
    final playerBusted = _playerScore > 21;
    final dealerBusted = _dealerScore > 21;
    final result = BlackJackLogic.evaluateGame(_playerScore, _dealerScore, playerBusted, dealerBusted);
    final multiplier = WinrateAlgorithm.calculateWinMultiplier('blackjack', _balance + _bet, _initialBalance, _bet) * (result == 'blackjack' ? 1.5 : result == 'won' ? 1.0 : result == 'push' ? 0.5 : 0.0);
    final winAmount = (_bet * multiplier).round();

    setState(() {
      _gameStatus = 'finished';
      _showDealerCard = true;
      _balance += winAmount;
      
      if (_balance <= 0) {
        _balance = 1000;
        _message = '🎁 Kayıp Bonusu! +1000 ₺ verildi!';
        BonusPopup.show(context, backgroundColor: Colors.green.shade800);
      } else {
        // Sonuç popup'ını göster
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            BlackjackResultPopup.show(
              context,
              result: result,
              winAmount: winAmount,
              bet: _bet,
            );
          }
        });
        
        switch (result) {
          case 'blackjack':
            _message = 'BLACKJACK! +$winAmount ₺ 🎉';
            break;
          case 'won':
            _message = 'Kazandınız! +$winAmount ₺ 🎊';
            break;
          case 'push':
            _message = 'Berabere! +$winAmount ₺ 🤝';
            break;
          default:
            _message = 'Kaybettiniz 😞';
        }
      }
    });

    _saveGameData();
    
    if (winAmount > _bet) {
      HapticFeedback.heavyImpact();
    }
  }

  void _increaseBet() {
    if (_gameStatus == 'betting' && _bet < _balance) {
      setState(() => _bet += 5);
    }
  }

  void _decreaseBet() {
    if (_gameStatus == 'betting' && _bet > 5) {
      setState(() => _bet -= 5);
    }
  }

  void _showBetDialog() {
    final TextEditingController controller = TextEditingController(text: _bet.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Bahis Miktarı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mevcut Bakiye: $_balance ₺'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Bahis miktarı',
                prefixIcon: Icon(Icons.casino),
                border: OutlineInputBorder(),
                suffixText: '₺',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount >= 5 && amount <= _balance) {
                setState(() {
                  _bet = amount;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _newGame() {
    setState(() {
      _gameStatus = 'betting';
      _playerCards.clear();
      _dealerCards.clear();
      _playerScore = 0;
      _dealerScore = 0;
      _message = 'Bahis yapın ve oyuna başlayın!';
      _showDealerCard = false;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B4513), // Kahverengi (ahşap)
                const Color(0xFFD2691E), // Açık kahverengi
                const Color(0xFF654321), // Koyu kahverengi
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B4513).withValues(alpha: 0.7),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              '🃏 BLACKJACK',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Koyu mavi
              Color(0xFF3F51B5), // İndigo
              Color(0xFF9C27B0), // Mor
              Color(0xFFE91E63), // Pembe
              Color(0xFFFF5722), // Turuncu
              Color(0xFF4CAF50), // Yeşil
              Color(0xFF00BCD4), // Cyan
            ],
            stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.8, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BlackjackBalance(
                balance: _balance,
                bet: _bet,
                gameStatus: _gameStatus,
                pulseController: _pulseController,
                onBetTap: _showBetDialog,
              ),
              
              const SizedBox(height: 20),
              
              BlackjackCards(
                cards: _dealerCards,
                score: _dealerScore,
                title: 'DEALER',
                color: Colors.red,
                icon: Icons.person,
                hideSecondCard: !_showDealerCard,
              ),
              
              const Spacer(),
              
              BlackjackMessage(
                message: _message,
                gameStatus: _gameStatus,
                pulseController: _pulseController,
              ),
              
              const Spacer(),
              
              BlackjackCards(
                cards: _playerCards,
                score: _playerScore,
                title: 'SİZ',
                color: Colors.blue,
                icon: Icons.person_outline,
              ),
              
              const SizedBox(height: 30),
              
              BlackjackButtons(
                gameStatus: _gameStatus,
                pulseController: _pulseController,
                onDecreaseBet: _decreaseBet,
                onIncreaseBet: _increaseBet,
                onStartGame: _startNewGame,
                onHit: _hit,
                onStand: _stand,
                onNewGame: _newGame,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}