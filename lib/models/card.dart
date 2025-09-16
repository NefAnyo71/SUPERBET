class Card {
  final String suit; // ♠️♥️♦️♣️
  final String rank; // A,2,3...K
  final int value;

  Card(this.suit, this.rank, this.value);

  String get display => '$rank$suit';
  
  bool get isAce => rank == 'A';
}