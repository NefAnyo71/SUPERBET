import 'dart:math';
import '../models/slot_symbol.dart';

class GameLogic {
  static final Random _rand = Random();

  static int evaluateResult(List<int> reels, List<SlotSymbol> symbols, int bet, int balance, int initialBalance) {
    final s0 = reels[0];
    final s1 = reels[1];
    final s2 = reels[2];
    final s3 = reels[3];
    final s4 = reels[4];

    // Başlangıç bakiyesine göre dinamik kazanma oranı hesapla
    final winBoost = _calculateWinBoost(balance, initialBalance);

    // 5 aynı sembol - ULTRA JACKPOT
    if (s0 == s1 && s1 == s2 && s2 == s3 && s3 == s4) {
      return bet * symbols[s0].multiplier * 10;
    }

    // 4 aynı sembol - MEGA JACKPOT
    if (s0 == s1 && s1 == s2 && s2 == s3) {
      return bet * symbols[s0].multiplier * 5;
    }

    // 3 aynı sembol - JACKPOT
    if (s0 == s1 && s1 == s2) {
      return bet * symbols[s0].multiplier * 2;
    }

    // 2 aynı sembol
    if (s0 == s1) {
      return (bet * symbols[s0].multiplier * 0.8).round();
    }

    // Yüksek değerli sembol şansı (dinamik)
    if (symbols[s0].multiplier >= 10 || symbols[s1].multiplier >= 10 || 
        symbols[s2].multiplier >= 10 || symbols[s3].multiplier >= 10 || symbols[s4].multiplier >= 10) {
      final chance = _rand.nextDouble();
      if (chance < (0.08 * winBoost)) {
        return (bet * 1.2).round();
      }
    }

    // Rastgele küçük kazanç şansı (dinamik)
    final randomChance = _rand.nextDouble();
    if (randomChance < (0.05 * winBoost)) {
      return (bet * 0.8).round();
    }

    return 0;
  }

  static double _calculateWinBoost(int balance, int initialBalance) {
    // Başlangıç bakiyesine göre algoritma winrate ayarlıcak
    final balanceRatio = balance / initialBalance;
    
    // Bakiye %10'un altında ise - AÇIL DURUM (Kazanma %90)
    if (balanceRatio <= 0.1) {
      return 18.0; // %90 kazanma şansı
    }
    // Bakiye %20'nin altında ise - KURTARMA MODU (Kazanma %80)
    else if (balanceRatio <= 0.2) {
      return 16.0; // %80 kazanma şansı
    }
    // Bakiye %30'un altında ise - YARDİM MODU (Kazanma %60)
    else if (balanceRatio <= 0.3) {
      return 12.0; // %60 kazanma şansı
    }
    // Bakiye %50'nin altında ise - DESTEK MODU (Kazanma %40)
    else if (balanceRatio <= 0.5) {
      return 8.0; // %40 kazanma şansı
    }
    // Bakiye ana paranın 2 katı ise - KAYBET MODU (Kazanma %7.5)
    else if (balanceRatio >= 2.0) {
      return 0.15; // %7.5 kazanma şansı (%92.5 kaybetme)
    }
    // Bakiye ana paranın 3 katı ise - HİZLI KAYBET MODU (Kazanma %5)
    else if (balanceRatio >= 3.0) {
      return 0.1; // %5 kazanma şansı (%95 kaybetme)
    }
    // Bakiye ana paranın 5 katı ise - ULTRA KAYBET MODU (Kazanma %2)
    else if (balanceRatio >= 5.0) {
      return 0.04; // %2 kazanma şansı (%98 kaybetme)
    }
    
    return 1.0; // Normal şans (%25)
  }

  static String getWinMessage(List<int> reels, List<SlotSymbol> symbols, int winAmount, int balance) {
    final s0 = reels[0];
    final s1 = reels[1];
    final s2 = reels[2];
    final s3 = reels[3];
    final s4 = reels[4];

    if (winAmount == 0) {
      return 'Maalesef — ${symbols[s0].emoji} ${symbols[s1].emoji} ${symbols[s2].emoji} ${symbols[s3].emoji} ${symbols[s4].emoji}';
    }

    if (s0 == s1 && s1 == s2 && s2 == s3 && s3 == s4) {
      return 'ULTRA JACKPOT! 5× ${symbols[s0].emoji} — $winAmount ₺';
    }

    if (s0 == s1 && s1 == s2 && s2 == s3) {
      return 'MEGA JACKPOT! 4× ${symbols[s0].emoji} — $winAmount ₺';
    }

    if (s0 == s1 && s1 == s2) {
      return 'JACKPOT! 3× ${symbols[s0].emoji} — $winAmount ₺';
    }

    if (s0 == s1) {
      return 'İyi! 2× ${symbols[s0].emoji} — $winAmount ₺';
    }

    if (symbols[s0].multiplier >= 10 || symbols[s1].multiplier >= 10 || 
        symbols[s2].multiplier >= 10 || symbols[s3].multiplier >= 10 || symbols[s4].multiplier >= 10) {
      return 'Küçük kazanç! — $winAmount ₺';
    }

    return 'Şanslı spin! — $winAmount ₺';
  }

  static bool isJackpot(List<int> reels, int balance) {
    final s0 = reels[0];
    final s1 = reels[1];
    final s2 = reels[2];
    final s3 = reels[3];
    final s4 = reels[4];

    return (s0 == s1 && s1 == s2 && s2 == s3 && s3 == s4) ||
           (s0 == s1 && s1 == s2 && s2 == s3) ||
           (s0 == s1 && s1 == s2);
  }
}