import 'package:flutter/material.dart';
import 'models/flashcard_model.dart';

class DeckManagerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> decks;
  final Function(int) onDeleteDeck;
  final Function(int, int) onDeleteFlashcard;

  const DeckManagerScreen({
    super.key,
    required this.decks,
    required this.onDeleteDeck,
    required this.onDeleteFlashcard,
  });

  @override
  State<DeckManagerScreen> createState() => _DeckManagerScreenState();
}

class _DeckManagerScreenState extends State<DeckManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Your Decks')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.decks.length,
        itemBuilder: (context, deckIndex) {
          final deck = widget.decks[deckIndex];
          final List<Flashcard> flashcards = deck['flashcards'];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(deck['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onDeleteDeck(deckIndex);
                  setState(() {});
                },
              ),
              children: [
                if (flashcards.isEmpty)
                  const ListTile(
                    title: Text('No flashcards in this deck.'),
                  )
                else
                  ...flashcards.asMap().entries.map((entry) {
                    int cardIndex = entry.key;
                    Flashcard card = entry.value;
                    return ListTile(
                      title: Text(card.question),
                      subtitle: Text(card.answer),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          widget.onDeleteFlashcard(deckIndex, cardIndex);
                          setState(() {});
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}