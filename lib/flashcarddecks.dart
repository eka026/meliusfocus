import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'flashcardQnA.dart';
import 'deck_manager.dart';
import 'models/flashcard_model.dart';
import 'providers/flashcard_provider.dart';

class FlashcardDecksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("FlashcardDecksScreen: Building screen");
    final user = FirebaseAuth.instance.currentUser;
    print("FlashcardDecksScreen: Current user: ${user?.uid}");
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to use flashcards'),
        ),
      );
    }

    return FlashcardDecksView();
  }
}

class FlashcardDecksView extends StatefulWidget {
  @override
  State<FlashcardDecksView> createState() => _FlashcardDecksViewState();
}

class _FlashcardDecksViewState extends State<FlashcardDecksView> {
  @override
  void initState() {
    super.initState();
    print("FlashcardDecksView: initState called");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("FlashcardDecksView: didChangeDependencies called");
  }

  void _addFlashcard(BuildContext context, int index) {
    print("FlashcardDecksView: Adding flashcard to deck at index $index");
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
              onPressed: () async {
                if (question.trim().isNotEmpty && answer.trim().isNotEmpty) {
                  print("FlashcardDecksView: Adding flashcard with Q: $question, A: $answer");
                  await context.read<FlashcardProvider>().addFlashcard(
                    index,
                    question.trim(),
                    answer.trim(),
                  );
                  print("FlashcardDecksView: Flashcard added, closing dialog");
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewDeck(BuildContext context) {
    print("FlashcardDecksView: Creating new deck");
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
              onPressed: () async {
                if (newDeckName.trim().isNotEmpty) {
                  print("FlashcardDecksView: Creating deck with name: ${newDeckName.trim()}");
                  await context.read<FlashcardProvider>().createDeck(newDeckName.trim());
                  print("FlashcardDecksView: Deck created, closing dialog");
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _openDeck(BuildContext context, int index) {
    final provider = context.read<FlashcardProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          flashcards: List<Flashcard>.from(provider.decks[index]['flashcards']),
        ),
      ),
    );
  }

  void _manageDecks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeckManagerScreen(
          decks: context.read<FlashcardProvider>().decks,
          onDeleteDeck: (index) async {
            await context.read<FlashcardProvider>().deleteDeck(index);
          },
          onDeleteFlashcard: (deckIndex, cardIndex) async {
            await context.read<FlashcardProvider>().deleteFlashcard(deckIndex, cardIndex);
          },
        ),
      ),
    );
  }

  Widget _buildCreateDeckButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _createNewDeck(context),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '+  Create new deck.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("FlashcardDecksView: Building view");
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          print("FlashcardDecksView: Consumer rebuilding with ${provider.decks.length} decks");
          print("FlashcardDecksView: Current decks: ${provider.decks}");
          
          if (provider.isLoading) {
            print("FlashcardDecksView: Showing loading indicator");
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            print("FlashcardDecksView: Showing error: ${provider.error}");
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: provider.decks.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No decks yet. Create your first deck!',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        _buildCreateDeckButton(context),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...provider.decks.asMap().entries.map((entry) {
                          int index = entry.key;
                          var deck = entry.value;
                          print("FlashcardDecksView: Building deck item: ${deck['title']}");
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () => _openDeck(context, index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deck['title'],
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Total cards: ${deck['flashcards'].length}', style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _addFlashcard(context, index),
                                      child: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        shape: const StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        _buildCreateDeckButton(context),
                      ],
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _manageDecks(context),
                  icon: const Icon(Icons.settings),
                  label: const Text('Manage your decks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: const StadiumBorder(),
                    elevation: 2,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}