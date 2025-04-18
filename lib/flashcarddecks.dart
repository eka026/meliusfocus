import 'package:flutter/material.dart';

class FlashcardDecksScreen extends StatelessWidget {
  final List<Map<String, dynamic>> decks = [
    {'title': 'CS310', 'total': 42, 'review': 12},
    {'title': 'CS306', 'total': 67, 'review': 23},
    {'title': 'CS307', 'total': 89, 'review': 34},
  ];

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
                ...decks.map((deck) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
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
                                  Text('Total cards: ${deck['total']}'),
                                  Text('Review: ${deck['review']}'),
                                ]),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/flashcard');
                              },
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
                    )),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
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
