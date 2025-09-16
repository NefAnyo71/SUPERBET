import 'dart:async';
import 'package:flutter/services.dart';
import '../models/card.dart';
import '../services/blackjack_logic.dart';
import '../services/storage_service.dart';

class BlackjackGameService {
  static Future<void> saveGameData({
    required int balance,
    required int initialBalance,
  }) async {
    await StorageService.saveGameData(
      balance: balance,
      initialBalance: initialBalance,
      totalBets: 0,
      totalWins: 0,
      gamesPlayed: 0,
      gameHistory: [],
    );
  }

  static Future<Map<String, dynamic>> loadGameData() async {
    return await StorageService.loadGameData();
  }

  static List<Card> createNewDeck() {
    return BlackJackLogic.createDeck();
  }

  static void dealInitialCards({
    required List<Card> deck,
    required List<Card> playerCards,
    required List<Card> dealerCards,
  }) {
    playerCards.add(deck.removeLast());
    dealerCards.add(deck.removeLast());
    playerCards.add(deck.removeLast());
    dealerCards.add(deck.removeLast());
  }

  static int calculateScore(List<Card> cards) {
    return BlackJackLogic.calculateScore(cards);
  }

  static String evaluateGameResult(int playerScore, int dealerScore, bool playerBusted, bool dealerBusted) {
    return BlackJackLogic.evaluateGame(playerScore, dealerScore, playerBusted, dealerBusted);
  }

  static double getWinMultiplier(String result, int balance, int initialBalance, int bet) {
    return BlackJackLogic.getWinMultiplier(result, balance, initialBalance, bet);
  }

  static bool shouldPlayerWin(int balance, int initialBalance, int bet) {
    return BlackJackLogic.shouldPlayerWin(balance, initialBalance, bet);
  }

  static bool shouldDealerHit(int dealerScore) {
    return BlackJackLogic.shouldDealerHit(dealerScore);
  }

  static void playHapticFeedback({bool heavy = false}) {
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> dealerPlayLogic({
    required List<Card> deck,
    required List<Card> dealerCards,
    required Function(int) onScoreUpdate,
    required bool shouldPlayerWin,
    required int dealerScore,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    while (shouldDealerHit(dealerScore)) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (shouldPlayerWin && dealerScore >= 15 && dealerScore <= 16) {
        final bustCard = deck.firstWhere(
          (card) => card.value + dealerScore > 21, 
          orElse: () => deck.last
        );
        deck.remove(bustCard);
        dealerCards.add(bustCard);
        final newScore = calculateScore(dealerCards);
        onScoreUpdate(newScore);
        break;
      } else {
        dealerCards.add(deck.removeLast());
        final newScore = calculateScore(dealerCards);
        onScoreUpdate(newScore);
      }
    }
  }
}