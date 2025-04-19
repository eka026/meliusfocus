import 'package:flutter/material.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, String>> flashcards;

  const FlashcardScreen({super.key, required this.flashcards});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool showQuestion = true;

  void flipCard() {
    setState(() {
      showQuestion = !showQuestion;
    });
  }

  void nextCard() {
    setState(() {
      showQuestion = true;
      currentIndex = (currentIndex + 1) % widget.flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Flashcards')),
        body: Center(child: Text('No flashcards in this deck.')),
      );
    }

    final current = widget.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Flashcards')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: flipCard,
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Center(
                child: Text(
                  showQuestion ? current['q']! : current['a']!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextCard,
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}
