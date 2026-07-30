import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SameAnswerApp());
}

class SameAnswerApp extends StatelessWidget {
  const SameAnswerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Same Answer Puzzle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PuzzleScreen(),
      },
    );
  }
}

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final Random _random = Random();
  late int _targetAnswer;
  late List<EquationCard> _cards;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    _targetAnswer = _random.nextInt(20) + 10; // Target between 10 and 29
    _cards = [];

    // Generate 4 correct equations
    _cards.add(_generateEquation(_targetAnswer, true));
    _cards.add(_generateEquation(_targetAnswer, true));
    _cards.add(_generateEquation(_targetAnswer, true));
    _cards.add(_generateEquation(_targetAnswer, true));

    // Generate 5 incorrect equations
    for (int i = 0; i < 5; i++) {
      int wrongAnswer;
      do {
        wrongAnswer = _targetAnswer + _random.nextInt(10) - 5;
      } while (wrongAnswer == _targetAnswer);
      _cards.add(_generateEquation(wrongAnswer, false));
    }

    _cards.shuffle();
    setState(() {});
  }

  EquationCard _generateEquation(int target, bool isCorrect) {
    int type = _random.nextInt(3); // 0: add, 1: sub, 2: mult
    String equation = "";

    switch (type) {
      case 0: // Addition
        int a = _random.nextInt(target);
        int b = target - a;
        equation = "$a + $b";
        break;
      case 1: // Subtraction
        int a = target + _random.nextInt(20);
        int b = a - target;
        equation = "$a - $b";
        break;
      case 2: // Multiplication (simplified for clean integers)
        List<int> factors = [];
        for (int i = 1; i <= target; i++) {
          if (target % i == 0) factors.add(i);
        }
        int a = factors[_random.nextInt(factors.length)];
        int b = target ~/ a;
        equation = "$a × $b";
        break;
    }

    return EquationCard(
      equation: equation,
      isCorrect: isCorrect,
    );
  }

  void _handleCardTap(int index) {
    if (_cards[index].isRevealed) return;

    setState(() {
      _cards[index].isRevealed = true;
      if (_cards[index].isCorrect) {
        _score += 10;
        // Check if all correct ones are found
        if (_cards.where((c) => c.isCorrect && c.isRevealed).length == 4) {
          _showWinDialog();
        }
      } else {
        _score -= 5;
      }
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Solved!'),
        content: Text('You found all equations that equal $_targetAnswer.\n\nScore: $_score'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _generatePuzzle();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text('Different Paths, Same Answer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Target Answer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_targetAnswer',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select the 4 correct equations:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Score: $_score',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return _buildCard(card, () => _handleCardTap(index));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePuzzle,
        icon: const Icon(Icons.refresh),
        label: const Text('New Puzzle'),
      ),
    );
  }

  Widget _buildCard(EquationCard card, VoidCallback onTap) {
    Color cardColor = Colors.white;
    Color textColor = Colors.black87;
    
    if (card.isRevealed) {
      if (card.isCorrect) {
        cardColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      } else {
        cardColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: card.isRevealed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
          border: Border.all(
            color: card.isRevealed 
                ? (card.isCorrect ? Colors.green.shade300 : Colors.red.shade300)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            card.equation,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class EquationCard {
  final String equation;
  final bool isCorrect;
  bool isRevealed;

  EquationCard({
    required this.equation,
    required this.isCorrect,
    this.isRevealed = false,
  });
}
