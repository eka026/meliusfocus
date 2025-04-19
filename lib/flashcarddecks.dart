import 'package:flutter/material.dart';
import 'flashcardQnA.dart';

class FlashcardDecksScreen extends StatefulWidget {
  @override
  State<FlashcardDecksScreen> createState() => _FlashcardDecksScreenState();
}

class _FlashcardDecksScreenState extends State<FlashcardDecksScreen> {
  List<Map<String, dynamic>> decks = [
    {
      'title': 'CS310',
      'flashcards': [
        {'q': 'What is Flutter?', 'a': 'A UI toolkit from Google'},
        {'q': 'Who developed Dart?', 'a': 'Google'},
      ],
      'review': 0
    },
    {
      'title': 'CS306',
      'flashcards': [
        {'q': 'What is a foreign key?', 'a': 'A field referencing another table'},
      ],
      'review': 0
    },
    {
      'title': 'CS307',
      'flashcards': [],
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
                    decks[index]['flashcards'].add({'q': question, 'a': answer});
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
                if (newDeckName.trim().isNotEmpty) {
                  setState(() {
                    decks.add({
                      'title': newDeckName.trim(),
                      'flashcards': <Map<String, String>>[], // explicitly typed
                      'review': 0,
                    });
                  });
                  Navigator.pop(context);
                }
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
          flashcards: List<Map<String, String>>.from(decks[index]['flashcards']),
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
                                  Text(
                                      'Total cards: ${deck['flashcards'].length}'),
                                  Text('Review: ${deck['review']}'),
                                ]),
                            ElevatedButton(
                              onPressed: () => _addFlashcard(index),
                              child: Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black,
                                shape: StadiumBorder(),
                              ),
                            )
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
              onPressed: () {},
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
