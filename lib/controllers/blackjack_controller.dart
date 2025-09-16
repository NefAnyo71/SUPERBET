import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';
import '../services/blackjack_game_service.dart';
import '../widgets/bonus_popup.dart';
import '../widgets/blackjack_result_popup.dart';

class BlackjackController extends ChangeNotifier {
  List<Card> _deck = [];
  final List<Card> _playerCards = [];
  final List<Card> _dealerCards = [];
  int _balance = 1000;
  int _initialBalance = 1000;
  int _bet = 10;
  int _playerScore = 0;
  int _dealerScore = 0;
  String _gameStatus = 'betting';
  String _message = 'Bahis yapın ve oyuna başlayın!';
  bool _showDealerCard = false;

  // Getters
  List<Card> get playerCards => _playerCards;
  List<Card> get dealerCards => _dealerCards;
  int get balance => _balance;
  int get bet => _bet;
  int get playerScore => _playerScore;
  int get dealerScore => _dealerScore;
  String get gameStatus => _gameStatus;
  String get message => _message;
  bool get showDealerCard => _showDealerCard;

  Future<void> loadGameData() async {
    final data = await BlackjackGameService.loadGameData();
    _balance = data['balance'];
    _initialBalance = data['initialBalance'] ?? 1000;
    notifyListeners();
  }

  void startNewGame() {
    if (_balance < _bet) {
      _message = 'Bakiye yetersiz!';
      notifyListeners();
      return;
    }

    _deck = BlackjackGameService.createNewDeck();
    _playerCards.clear();
    _dealerCards.clear();
    _balance -= _bet;
    _gameStatus = 'playing';
    _showDealerCard = false;
    _message = 'Kartlarınız dağıtılıyor...';
    
    BlackjackGameService.dealInitialCards(
      deck: _deck,
      playerCards: _playerCards,
      dealerCards: _dealerCards,
    );
    
    _playerScore = BlackjackGameService.calculateScore(_playerCards);
    _dealerScore = BlackjackGameService.calculateScore(_dealerCards);
    
    if (_playerScore == 21) {
      _message = 'BLACKJACK! 🎉';
      endGame();
    } else {
      _message = 'Hit veya Stand seçin';
    }
    
    notifyListeners();
  }

  void hit() {
    if (_gameStatus != 'playing') return;

    _playerCards.add(_deck.removeLast());
    _playerScore = BlackjackGameService.calculateScore(_playerCards);
    
    if (_playerScore > 21) {
      _message = 'Bust! Kaybettiniz 😞';
      endGame();
    } else if (_playerScore == 21) {
      _message = '21! Mükemmel 🎯';
      stand();
    } else {
      _message = 'Hit veya Stand seçin';
    }

    BlackjackGameService.playHapticFeedback();
    notifyListeners();
  }

  void stand() {
    if (_gameStatus != 'playing') return;

    _gameStatus = 'dealer';
    _showDealerCard = true;
    _message = 'Dealer kartlarını çekiyor...';
    notifyListeners();

    dealerPlay();
  }

  Future<void> dealerPlay() async {
    final shouldPlayerWin = BlackjackGameService.shouldPlayerWin(
      _balance + _bet, 
      _initialBalance, 
      _bet
    );
    
    await BlackjackGameService.dealerPlayLogic(
      deck: _deck,
      dealerCards: _dealerCards,
      onScoreUpdate: (newScore) {
        _dealerScore = newScore;
        notifyListeners();
      },
      shouldPlayerWin: shouldPlayerWin,
      dealerScore: _dealerScore,
    );

    endGame();
  }

  void endGame() {
    final playerBusted = _playerScore > 21;
    final dealerBusted = _dealerScore > 21;
    final result = BlackjackGameService.evaluateGameResult(
      _playerScore, 
      _dealerScore, 
      playerBusted, 
      dealerBusted
    );
    final multiplier = BlackjackGameService.getWinMultiplier(
      result, 
      _balance + _bet, 
      _initialBalance, 
      _bet
    );
    final winAmount = (_bet * multiplier).round();

    _gameStatus = 'finished';
    _showDealerCard = true;
    _balance += winAmount;
    
    if (_balance <= 0) {
      _balance = 1000;
      _message = '🎁 Kayıp Bonusu! +1000 ₺ verildi!';
    } else {
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

    BlackjackGameService.saveGameData(
      balance: _balance,
      initialBalance: _initialBalance,
    );
    
    if (winAmount > _bet) {
      BlackjackGameService.playHapticFeedback(heavy: true);
    }
    
    notifyListeners();
  }

  void showResultPopup(BuildContext context, String result, int winAmount) {
    if (_balance > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          BlackjackResultPopup.show(
            context,
            result: result,
            winAmount: winAmount,
            bet: _bet,
          );
        }
      });
    } else {
      BonusPopup.show(context, backgroundColor: Colors.green.shade800);
    }
  }

  void increaseBet() {
    if (_gameStatus == 'betting' && _bet < _balance) {
      _bet += 5;
      notifyListeners();
    }
  }

  void decreaseBet() {
    if (_gameStatus == 'betting' && _bet > 5) {
      _bet -= 5;
      notifyListeners();
    }
  }

  void setBet(int amount) {
    if (_gameStatus == 'betting' && amount >= 5 && amount <= _balance) {
      _bet = amount;
      notifyListeners();
    }
  }

  void newGame() {
    _gameStatus = 'betting';
    _playerCards.clear();
    _dealerCards.clear();
    _playerScore = 0;
    _dealerScore = 0;
    _message = 'Bahis yapın ve oyuna başlayın!';
    _showDealerCard = false;
    notifyListeners();
  }
}