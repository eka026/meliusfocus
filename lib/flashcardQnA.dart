import 'package:flutter/material.dart';
import 'models/flashcard_model.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const FlashcardScreen({super.key, required this.flashcards});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool showQuestion = true;

  void flipCard() {
    setState(() => showQuestion = !showQuestion);
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
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No flashcards in this deck.')),
      );
    }

    final current = widget.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: flipCard,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Center(
                child: Text(
                  showQuestion ? current.question : current.answer,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextCard,
            child: const Text('Next Question'),
          ),
        ],
      ),
    );
  }
}