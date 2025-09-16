import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/slot_symbol.dart';
import '../models/game_history.dart';
import '../services/game_logic.dart';
import '../services/winrate_algorithm.dart';
import '../services/storage_service.dart';
import '../widgets/balance_display.dart';
import '../widgets/slot_machine.dart';
import '../widgets/message_area.dart';
import '../widgets/spin_button.dart';
import '../widgets/neon_button.dart';
import '../widgets/bonus_popup.dart';

class SlotGame extends StatefulWidget {
  const SlotGame({super.key});
  @override
  State<SlotGame> createState() => _SlotGameState();
}

class _SlotGameState extends State<SlotGame> with TickerProviderStateMixin {
  final Random _rand = Random();
  final List<SlotSymbol> _symbols = [
    SlotSymbol('🍒', 2, Colors.red),
    SlotSymbol('🍋', 3, Colors.yellow),
    SlotSymbol('🔔', 5, Colors.amber),
    SlotSymbol('💎', 10, Colors.cyan),
    SlotSymbol('7️⃣', 20, Colors.purple),
    SlotSymbol('🍊', 4, Colors.orange),
    SlotSymbol('⭐', 8, Colors.yellow),
    SlotSymbol('🎰', 15, Colors.red),
    SlotSymbol('💰', 12, Colors.green),
    SlotSymbol('🎲', 6, Colors.blue),
  ];

  late List<int> _reels;
  bool _spinning = false;
  int _balance = 1000;
  int _initialBalance = 1000;
  int _bet = 1;
  String _message = 'Spin butonuna bas!';
  int _winAmount = 0;
  bool _showWinAnimation = false;
  late AnimationController _winAnimationController;
  late AnimationController _pulseController;
  late AnimationController _neonController;
  final List<AnimationController> _reelControllers = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<GameHistory> _gameHistory = [];
  int _totalBets = 0;
  int _totalWins = 0;
  int _gamesPlayed = 0;
  bool _isJackpot = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _reels = List<int>.generate(5, (_) => _rand.nextInt(_symbols.length));
    _initAnimations();
    _loadGameData();
  }

  void _initAnimations() {
    _winAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _neonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    for (int i = 0; i < 5; i++) {
      _reelControllers.add(
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  Future<void> _loadGameData() async {
    final data = await StorageService.loadGameData();
    setState(() {
      _balance = data['balance'];
      _initialBalance = data['initialBalance'] ?? 1000;
      _totalBets = data['totalBets'];
      _totalWins = data['totalWins'];
      _gamesPlayed = data['gamesPlayed'];
      _gameHistory.clear();
      _gameHistory.addAll(data['gameHistory']);
    });
  }

  Future<void> _saveGameData() async {
    await StorageService.saveGameData(
      balance: _balance,
      initialBalance: _initialBalance,
      totalBets: _totalBets,
      totalWins: _totalWins,
      gamesPlayed: _gamesPlayed,
      gameHistory: _gameHistory,
    );
  }

  void _playSound(String type) async {
    if (_isMuted) return;
    try {
      if (type == 'spin') {
        await _audioPlayer.play(AssetSource('mp3/slot.mp3'));
      }
    } catch (e) {
      // Ses çalma hatası
    }
  }

  void _spin() async {
    if (_spinning || _balance < _bet) {
      if (_balance < _bet) {
        setState(() => _message = 'Bakiye yetersiz.');
      }
      return;
    }

    setState(() {
      _spinning = true;
      _balance -= _bet;
      _message = 'Çeviriliyor...';
      _winAmount = 0;
      _showWinAnimation = false;
      _isJackpot = false;
    });

    HapticFeedback.mediumImpact();
    _playSound('spin');
    
    await _animateReels();
    _evaluateResult();
    _updateGameHistory();
    _saveGameData();
    _playResultSound();
  }

  Future<void> _animateReels() async {
    final delays = [0, 100, 200, 300, 400];
    final futures = <Future>[];

    for (int i = 0; i < 5; i++) {
      final completer = Completer();
      futures.add(completer.future);

      Timer(Duration(milliseconds: delays[i]), () {
        _reelControllers[i].reset();
        _reelControllers[i].forward().then((_) {
          setState(() {
            _reels[i] = _rand.nextInt(_symbols.length);
          });
          completer.complete();
        });
      });
    }

    await Future.wait(futures);
  }

  void _evaluateResult() {
    final shouldWin = WinrateAlgorithm.shouldPlayerWin('slot', _balance + _bet, _initialBalance, _bet);
    _winAmount = shouldWin ? GameLogic.evaluateResult(_reels, _symbols, _bet, _balance + _bet, _initialBalance) : 0;
    if (shouldWin && _winAmount == 0) {
      _winAmount = (_bet * WinrateAlgorithm.calculateWinMultiplier('slot', _balance + _bet, _initialBalance, _bet)).round();
    }
    _balance += _winAmount;
    _message = GameLogic.getWinMessage(_reels, _symbols, _winAmount, _balance);
    _isJackpot = GameLogic.isJackpot(_reels, _balance);

    setState(() {
      _spinning = false;
      _showWinAnimation = _winAmount > 0;
    });

    if (_isJackpot) {
      HapticFeedback.heavyImpact();
    }
  }

  void _updateGameHistory() {
    final gameResult = GameHistory(
      date: DateTime.now(),
      bet: _bet,
      win: _winAmount,
      symbols: _reels.map((i) => _symbols[i].emoji).toList(),
      result: _winAmount > 0 ? 'Kazandı' : 'Kaybetti',
    );

    setState(() {
      _gameHistory.insert(0, gameResult);
      if (_gameHistory.length > 50) _gameHistory.removeLast();
      _totalBets += _bet;
      _totalWins += _winAmount;
      _gamesPlayed++;
      
      // Kayıp bonusu kontrolü
      if (_balance <= 0) {
        _balance = 1000;
        _message = '🎁 Kayıp Bonusu! +1000 ₺ verildi!';
        BonusPopup.show(context, backgroundColor: Colors.purple.shade800);
      }
    });
  }

  void _playResultSound() {
    if (_winAmount > 0) {
      _playSound('win');
      _winAnimationController.reset();
      _winAnimationController.repeat(reverse: true);
    } else {
      _playSound('lose');
    }
  }

  void _increaseBet() {
    setState(() {
      if (_bet + 1 <= _balance) {
        _bet += 1;
        _playSound('chip');
      }
    });
  }

  void _decreaseBet() {
    setState(() {
      if (_bet - 1 >= 1) {
        _bet -= 1;
        _playSound('chip');
      }
    });
  }

  void _maxBet() {
    setState(() {
      _bet = _balance;
      if (_bet < 1) _bet = 1;
      _playSound('chip');
    });
  }

  void _betDelete() {
    setState(() {
      _bet = 1;
      _playSound('chip');
    });
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
              if (amount != null && amount >= 1 && amount <= _balance) {
                setState(() {
                  _bet = amount;
                });
                Navigator.pop(context);
                _playSound('chip');
              }
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }



  void _showStats() {
    final profit = _totalWins - _totalBets;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İstatistikler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Oyun: $_gamesPlayed'),
            Text('Toplam Bahis: $_totalBets ₺'),
            Text('Toplam Kar: ${_totalWins - _totalBets} ₺'),
            const Divider(),
            Text(
              'Kar/Zarar: ${profit >= 0 ? '+' : ''}$profit ₺',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: profit >= 0 ? Colors.green : Colors.red,
              ),
            ),
            if (_gamesPlayed > 0)
              Text(
                'Kazanma Oranı: ${((_gameHistory.where((g) => g.win > 0).length / _gamesPlayed) * 100).toStringAsFixed(1)}%',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyun Geçmişi'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _gameHistory.length,
            itemBuilder: (context, index) {
              final game = _gameHistory[index];
              final profit = game.win - game.bet;
              return Card(
                child: ListTile(
                  leading: Text(game.symbols.join(' ')),
                  title: Text('Bahis: ${game.bet} ₺'),
                  subtitle: Text(
                    '${game.date.day}/${game.date.month} ${game.date.hour}:${game.date.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    '${profit >= 0 ? '+' : ''}$profit ₺',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _winAnimationController.dispose();
    _pulseController.dispose();
    _neonController.dispose();
    for (var controller in _reelControllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
            child: Column(
            children: [
              BalanceDisplay(
                balance: _balance,
                winAmount: _winAmount,
                pulseController: _pulseController,
              ),
              const SizedBox(height: 12),
              SlotMachine(
                reels: _reels,
                symbols: _symbols,
                spinning: _spinning,
                reelControllers: _reelControllers,
                neonController: _neonController,
                rand: _rand,
              ),
              if (_showWinAnimation) _buildWinAnimation(),
              const SizedBox(height: 14),
              MessageArea(
                message: _message,
                winAmount: _winAmount,
                pulseController: _pulseController,
              ),
              const SizedBox(height: 14),
              _buildBetControls(),
              const SizedBox(height: 12),
              _buildActionButtons(),
              const Spacer(),
              SpinButton(
                spinning: _spinning,
                onPressed: _spin,
                pulseController: _pulseController,
              ),
              const SizedBox(height: 10),
            ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(40),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withValues(alpha: 0.9),
              Colors.pink.withValues(alpha: 0.8),
              Colors.blue.withValues(alpha: 0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '🎰 SLOT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: _isMuted ? Colors.red : Colors.green,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
              },
            ),

            IconButton(
              icon: const Icon(Icons.analytics, color: Colors.amber, size: 22),
              onPressed: () => _showStats(),
            ),
            if (_gameHistory.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.history, color: Colors.cyan, size: 22),
                onPressed: () => _showHistory(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinAnimation() {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _winAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: RadialGradient(
                center: const Alignment(0, 0),
                radius: 1.0 + _winAnimationController.value * 0.5,
                colors: _isJackpot
                    ? [
                        Colors.amber.withValues(alpha: 0.8),
                        Colors.orange.withValues(alpha: 0.6),
                        Colors.yellow.withValues(alpha: 0.4),
                        Colors.transparent,
                      ]
                    : [
                        Colors.green.withValues(alpha: 0.6),
                        Colors.lime.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
              ),
            ),
            child: _isJackpot
                ? Center(
                    child: Text(
                      '🎆 JACKPOT! 🎆',
                      style: TextStyle(
                        fontSize: 20 + _winAnimationController.value * 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                        shadows: [
                          Shadow(
                            color: Colors.amber,
                            blurRadius: 15 + _winAnimationController.value * 15,
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBetControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NeonButton(
          onPressed: _spinning ? null : _decreaseBet,
          color: Colors.red,
          pulseController: _pulseController,
          child: const Icon(Icons.remove, color: Colors.white, size: 20),
        ),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return GestureDetector(
              onTap: _spinning ? null : _showBetDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.8),
                      Colors.pink.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.5 + _pulseController.value * 0.5,
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BAHIS: $_bet ₺',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.purple, blurRadius: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.edit,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        NeonButton(
          onPressed: _spinning ? null : _increaseBet,
          color: Colors.green,
          pulseController: _pulseController,
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NeonButton(
          onPressed: _spinning ? null : _maxBet,
          color: Colors.orange,
          pulseController: _pulseController,
          child: const Text(
            'MAX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        NeonButton(
          onPressed: _spinning ? null : _showStats,
          color: Colors.green,
          pulseController: _pulseController,
          child: const Text(
            'KAR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        NeonButton(
          onPressed: _spinning ? null : _betDelete,
          color: Colors.blue,
          pulseController: _pulseController,
          child: const Text(
            'RESET',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}