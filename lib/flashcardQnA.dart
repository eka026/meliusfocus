import 'package:flutter/material.dart';

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool showQuestion = true;
  final String question = "What is the capital of France?";
  final String answer = "Paris";

  void flipCard() {
    setState(() => showQuestion = !showQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flashcard")),
      body: Center(
        child: GestureDetector(
          onTap: flipCard,
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(16),
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Center(
              child: Text(
                showQuestion ? question : answer,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
