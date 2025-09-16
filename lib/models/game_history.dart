class GameHistory {
  final DateTime date;
  final int bet;
  final int win;
  final List<String> symbols;
  final String result;

  GameHistory({
    required this.date,
    required this.bet,
    required this.win,
    required this.symbols,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
    'date': date.millisecondsSinceEpoch,
    'bet': bet,
    'win': win,
    'symbols': symbols,
    'result': result,
  };

  factory GameHistory.fromJson(Map<String, dynamic> json) => GameHistory(
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    bet: json['bet'],
    win: json['win'],
    symbols: List<String>.from(json['symbols']),
    result: json['result'],
  );
}