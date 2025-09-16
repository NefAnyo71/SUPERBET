import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';
import 'card_widget.dart';

class CardAnimation extends StatefulWidget {
  final Card card;
  final bool isDealer;
  final int index;
  final bool showCard;

  const CardAnimation({
    super.key,
    required this.card,
    required this.isDealer,
    required this.index,
    this.showCard = true,
  });

  @override
  State<CardAnimation> createState() => _CardAnimationState();
}

class _CardAnimationState extends State<CardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 200)),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: widget.isDealer ? -200.0 : 200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: widget.isDealer ? -0.5 : 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: CardWidget(
                card: widget.card,
                isHidden: !widget.showCard,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardDealAnimation extends StatefulWidget {
  final List<Card> cards;
  final bool isDealer;
  final bool showDealerCard;

  const CardDealAnimation({
    super.key,
    required this.cards,
    required this.isDealer,
    this.showDealerCard = true,
  });

  @override
  State<CardDealAnimation> createState() => _CardDealAnimationState();
}

class _CardDealAnimationState extends State<CardDealAnimation> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: -30,
      children: widget.cards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final showCard = widget.isDealer 
            ? (index == 0 || widget.showDealerCard)
            : true;

        return CardAnimation(
          key: ValueKey('${widget.isDealer}_${index}_${card.suit}_${card.rank}'),
          card: card,
          isDealer: widget.isDealer,
          index: index,
          showCard: showCard,
        );
      }).toList(),
    );
  }
}