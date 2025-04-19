import 'package:flutter/material.dart';
import 'flashcardQnA.dart';
import 'deck_manager.dart';
import 'models/flashcard_model.dart';

class FlashcardDecksScreen extends StatefulWidget {
  @override
  State<FlashcardDecksScreen> createState() => _FlashcardDecksScreenState();
}

class _FlashcardDecksScreenState extends State<FlashcardDecksScreen> {
  List<Map<String, dynamic>> decks = [
    {
      'title': 'CS310',
      'flashcards': [
        Flashcard(question: 'What is Flutter?', answer: 'A UI toolkit from Google'),
        Flashcard(question: 'Who developed Dart?', answer: 'Google'),
      ],
      'review': 0
    },
    {
      'title': 'CS306',
      'flashcards': [
        Flashcard(question: 'What is a foreign key?', answer: 'A field referencing another table'),
      ],
      'review': 0
    },
    {
      'title': 'CS307',
      'flashcards': <Flashcard>[],
      'review': 0
    },
  ];

  void _addFlashcard(int index) {
    String question = '';
    String answer = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Question'),
                onChanged: (value) => question = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Answer'),
                onChanged: (value) => answer = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (question.trim().isNotEmpty && answer.trim().isNotEmpty) {
                  setState(() {
                    decks[index]['flashcards'].add(
                      Flashcard(question: question, answer: answer),
                    );
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewDeck() {
    String newDeckName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Deck'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Deck Name'),
            onChanged: (value) => newDeckName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String cleanedInput = newDeckName
                    .replaceAll(RegExp(r'\s+'), '')
                    .replaceAll(RegExp(r'[^\w]+'), '')
                    .toLowerCase();

                if (cleanedInput.isEmpty) return;

                bool exists = decks.any((deck) {
                  String normalized = deck['title']
                      .toString()
                      .replaceAll(RegExp(r'\s+'), '')
                      .replaceAll(RegExp(r'[^\w]+'), '')
                      .toLowerCase();
                  return normalized == cleanedInput;
                });

                if (exists) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('You already created this deck.'),
                      backgroundColor: Colors.red.shade400,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                setState(() {
                  decks.add({
                    'title': newDeckName.trim(),
                    'flashcards': <Flashcard>[],
                    'review': 0,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _openDeck(int index) {
    setState(() {
      decks[index]['review']++;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          flashcards: List<Flashcard>.from(decks[index]['flashcards']),
        ),
      ),
    );
  }

  void _manageDecks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeckManagerScreen(
          decks: decks,
          onDeleteDeck: (index) {
            setState(() => decks.removeAt(index));
          },
          onDeleteFlashcard: (deckIndex, cardIndex) {
            setState(() {
              decks[deckIndex]['flashcards'].removeAt(cardIndex);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flashcards')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                ...decks.asMap().entries.map((entry) {
                  int index = entry.key;
                  var deck = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () => _openDeck(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deck['title'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Total cards: ${deck['flashcards'].length}'),
                                Text('Review: ${deck['review']}'),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => _addFlashcard(index),
                              child: Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black,
                                shape: StadiumBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _createNewDeck,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('+  Create new deck.',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _manageDecks,
              icon: Icon(Icons.settings),
              label: Text('Manage your decks'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: StadiumBorder(),
                elevation: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}