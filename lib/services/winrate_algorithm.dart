import 'dart:math';

class WinrateAlgorithm {
  static final Random _rand = Random();

  // Blackjack için gelişmiş winrate hesaplama
  static double calculateBlackjackWinrate(int balance, int initialBalance, int bet) {
    final balanceRatio = balance / initialBalance;
    final betRatio = bet / balance; // Balance'a göre bet oranı
    
    // Temel winrate %45
    double baseWinrate = 0.45;
    
    // 10k altında özel boost
    if (balance < 10000) {
      final lowBalanceBoost = (10000 - balance) / 10000;
      baseWinrate = 0.45 + (lowBalanceBoost * 0.35); // %45'ten %80'e kadar
    }
    
    // Bakiye durumuna göre boost
    if (balanceRatio <= 0.1) {
      baseWinrate = 0.85; // %85 kazanma şansı - KURTARMA MODU
    } else if (balanceRatio <= 0.2) {
      baseWinrate = 0.75; // %75 kazanma şansı
    } else if (balanceRatio <= 0.3) {
      baseWinrate = 0.65; // %65 kazanma şansı
    } else if (balanceRatio <= 0.5) {
      baseWinrate = 0.55; // %55 kazanma şansı
    }
    
    // All-in koruması - bakiyenin %90+ bahis
    if (betRatio >= 0.9) {
      baseWinrate = 0.95; // %95 kazanma şansı
    } else if (betRatio >= 0.7) {
      baseWinrate = 0.85; // %85 kazanma şansı
    } else if (betRatio >= 0.5) {
      baseWinrate = 0.75; // %75 kazanma şansı
    }
    
    return baseWinrate.clamp(0.15, 0.95);
  }

  // Slot için gelişmiş winrate hesaplama
  static double calculateSlotWinrate(int balance, int initialBalance, int bet) {
    final balanceRatio = balance / initialBalance;
    final betRatio = bet / balance; // Balance'a göre bet oranı
    
    // Temel winrate %35
    double baseWinrate = 0.35;
    
    // 10k altında özel boost
    if (balance < 10000) {
      final lowBalanceBoost = (10000 - balance) / 10000;
      baseWinrate = 0.35 + (lowBalanceBoost * 0.45); // %35'ten %80'e kadar
    }
    
    // Bakiye durumuna göre boost
    if (balanceRatio <= 0.1) {
      baseWinrate = 0.70; // %70 kazanma şansı - KURTARMA MODU
    } else if (balanceRatio <= 0.2) {
      baseWinrate = 0.60; // %60 kazanma şansı
    } else if (balanceRatio <= 0.3) {
      baseWinrate = 0.50; // %50 kazanma şansı
    } else if (balanceRatio <= 0.5) {
      baseWinrate = 0.42; // %42 kazanma şansı
    }
    
    // All-in koruması - bakiyenin %90+ bahis
    if (betRatio >= 0.9) {
      baseWinrate = 0.90; // %90 kazanma şansı
    } else if (betRatio >= 0.7) {
      baseWinrate = 0.80; // %80 kazanma şansı
    } else if (betRatio >= 0.5) {
      baseWinrate = 0.70; // %70 kazanma şansı
    }
    
    return baseWinrate.clamp(0.1, 0.9);
  }

  // Kazanç çarpanı hesaplama
  static double calculateWinMultiplier(String gameType, int balance, int initialBalance, int bet) {
    final balanceRatio = balance / initialBalance;
    
    double baseMultiplier = gameType == 'blackjack' ? 2.0 : 2.5;
    
    // Düşük bakiyede kazanç boost
    if (balanceRatio <= 0.1) {
      baseMultiplier *= 2.5; // 2.5x boost
    } else if (balanceRatio <= 0.2) {
      baseMultiplier *= 2.0; // 2x boost
    } else if (balanceRatio <= 0.3) {
      baseMultiplier *= 1.5; // 1.5x boost
    }
    
    return baseMultiplier;
  }

  // Oyun sonucu belirleme
  static bool shouldPlayerWin(String gameType, int balance, int initialBalance, int bet) {
    final winrate = gameType == 'blackjack' 
        ? calculateBlackjackWinrate(balance, initialBalance, bet)
        : calculateSlotWinrate(balance, initialBalance, bet);
    
    return _rand.nextDouble() < winrate;
  }
}