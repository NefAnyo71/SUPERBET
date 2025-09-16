import 'dart:math';
import '../models/card.dart';

class BlackJackLogic {
  static final Random _rand = Random();

  static List<Card> createDeck() {
    final suits = ['♠️', '♥️', '♦️', '♣️'];
    final ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    final deck = <Card>[];

    for (String suit in suits) {
      for (String rank in ranks) {
        int value;
        if (rank == 'A') {
          value = 11; // As başlangıçta 11
        } else if (['J', 'Q', 'K'].contains(rank)) {
          value = 10;
        } else {
          value = int.parse(rank);
        }
        deck.add(Card(suit, rank, value));
      }
    }

    deck.shuffle(_rand);
    return deck;
  }

  static int calculateScore(List<Card> cards) {
    int score = 0;
    int aces = 0;

    for (Card card in cards) {
      if (card.isAce) {
        aces++;
        score += 11;
      } else {
        score += card.value;
      }
    }

    // As'ları 1 yap eğer 21'i geçiyorsa
    while (score > 21 && aces > 0) {
      score -= 10;
      aces--;
    }

    return score;
  }

  static String evaluateGame(int playerScore, int dealerScore, bool playerBusted, bool dealerBusted) {
    if (playerBusted) return 'lost';
    if (dealerBusted) return 'won';
    if (playerScore == 21 && dealerScore != 21) return 'blackjack';
    if (playerScore > dealerScore) return 'won';
    if (playerScore < dealerScore) return 'lost';
    return 'push';
  }

  static bool shouldDealerHit(int dealerScore) {
    return dealerScore < 17;
  }

  static double getWinMultiplier(String result, int balance, int initialBalance, int bet) {
    // Dinamik kazanma boost'u hesapla
    final winBoost = _calculateBlackjackWinBoost(balance, initialBalance, bet);
    
    switch (result) {
      case 'blackjack':
        return 2.5 * winBoost; // BlackJack 1.5:1 ödeme
      case 'won':
        return 2.0 * winBoost; // Normal kazanç 1:1
      case 'push':
        return 1.0; // Berabere, bahis geri (boost etkilemez)
      default:
        return 0.0; // Kaybetti
    }
  }

  static double _calculateBlackjackWinBoost(int balance, int initialBalance, int bet) {
    final balanceRatio = balance / initialBalance;
    final betRatio = bet / initialBalance;
    
    // Bakiye çok az ise - KURTARMA MODU
    if (balanceRatio <= 0.1) {
      return 3.0; // 3x kazanç boost
    } else if (balanceRatio <= 0.2) {
      return 2.5; // 2.5x kazanç boost
    } else if (balanceRatio <= 0.3) {
      return 2.0; // 2x kazanç boost
    } else if (balanceRatio <= 0.5) {
      return 1.5; // 1.5x kazanç boost
    }
    
    // Büyük bahis oynuyorsa - KAYBET MODU
    if (betRatio >= 0.1) { // Bahis ana paranın %10'u veya fazlası
      return 0.3; // Kazanç azalt
    } else if (betRatio >= 0.05) { // Bahis ana paranın %5'i veya fazlası
      return 0.6; // Kazanç azalt
    }
    
    return 1.0; // Normal kazanç
  }

  static bool shouldPlayerWin(int balance, int initialBalance, int bet) {
    final balanceRatio = balance / initialBalance;
    final betRatio = bet / initialBalance;
    final rand = Random();
    
    // Bakiye çok az ise - KAZANMA ŞANSI ARTIR
    if (balanceRatio <= 0.1) {
      return rand.nextDouble() < 0.8; // %80 kazanma şansı
    } else if (balanceRatio <= 0.2) {
      return rand.nextDouble() < 0.7; // %70 kazanma şansı
    } else if (balanceRatio <= 0.3) {
      return rand.nextDouble() < 0.6; // %60 kazanma şansı
    }
    
    // Büyük bahis oynuyorsa - KAYBETME ŞANSI ARTIR
    if (betRatio >= 0.1) {
      return rand.nextDouble() < 0.2; // %20 kazanma şansı
    } else if (betRatio >= 0.05) {
      return rand.nextDouble() < 0.3; // %30 kazanma şansı
    }
    
    return rand.nextDouble() < 0.45; // Normal %45 kazanma şansı
  }
}