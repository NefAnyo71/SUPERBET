import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history.dart';

class StorageService {
  static Future<Map<String, dynamic>> loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final balance = prefs.getInt('balance') ?? 1000;
    final initialBalance = prefs.getInt('initialBalance') ?? 1000;
    final totalBets = prefs.getInt('totalBets') ?? 0;
    final totalWins = prefs.getInt('totalWins') ?? 0;
    final gamesPlayed = prefs.getInt('gamesPlayed') ?? 0;

    final historyJson = prefs.getStringList('gameHistory') ?? [];
    final gameHistory = <GameHistory>[];
    
    for (String json in historyJson) {
      gameHistory.add(GameHistory.fromJson(jsonDecode(json)));
    }

    return {
      'balance': balance,
      'initialBalance': initialBalance,
      'totalBets': totalBets,
      'totalWins': totalWins,
      'gamesPlayed': gamesPlayed,
      'gameHistory': gameHistory,
    };
  }

  static Future<void> saveGameData({
    required int balance,
    required int initialBalance,
    required int totalBets,
    required int totalWins,
    required int gamesPlayed,
    required List<GameHistory> gameHistory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('balance', balance);
    await prefs.setInt('initialBalance', initialBalance);
    await prefs.setInt('totalBets', totalBets);
    await prefs.setInt('totalWins', totalWins);
    await prefs.setInt('gamesPlayed', gamesPlayed);

    final historyJson = gameHistory
        .map((h) => jsonEncode(h.toJson()))
        .toList();
    await prefs.setStringList('gameHistory', historyJson);
  }
}