import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/flashcard_model.dart';

class FlashcardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _decks = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get decks => _decks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FlashcardProvider() {
    print("FlashcardProvider: Initializing...");
    _auth.userChanges().listen((user) {
      print("FlashcardProvider: Auth state changed. User: [1m${user?.uid}[0m");
      _decks = [];
      if (user != null) {
        fetchDecks();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> fetchDecks() async {
    if (_auth.currentUser == null) {
      print("FlashcardProvider: No user logged in, skipping fetchDecks");
      return;
    }

    print("FlashcardProvider: Fetching decks for user ${_auth.currentUser!.uid}");
    _isLoading = true;
    _error = null;
    notifyListeners();
    print("FlashcardProvider: Notified listeners after setting loading state");

    try {
      final decksSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('decks')
          .get();

      print("FlashcardProvider: Fetched [1m${decksSnapshot.docs.length}[0m decks");

      _decks = decksSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'flashcards': (data['flashcards'] as List<dynamic>? ?? []).map((card) {
            return Flashcard(
              question: card['question'] ?? '',
              answer: card['answer'] ?? '',
            );
          }).toList(),
        };
      }).toList();

      print("FlashcardProvider: Processed decks: $_decks");
      _isLoading = false;
      notifyListeners();
      print("FlashcardProvider: Notified listeners after fetching decks");
    } catch (e) {
      print("FlashcardProvider: Error fetching decks: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print("FlashcardProvider: Notified listeners after error");
    }
  }

  Future<void> createDeck(String title) async {
    if (_auth.currentUser == null) {
      print("FlashcardProvider: No user logged in, skipping createDeck");
      return;
    }

    print("FlashcardProvider: Creating new deck with title: $title");
    try {
      final deckRef = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('decks')
          .add({
        'title': title,
        'flashcards': [],
      });

      print("FlashcardProvider: Created deck with ID: ${deckRef.id}");

      _decks.add({
        'id': deckRef.id,
        'title': title,
        'flashcards': [],
      });

      print("FlashcardProvider: Updated local decks list: $_decks");
      notifyListeners();
      print("FlashcardProvider: Notified listeners after creating deck");
    } catch (e) {
      print("FlashcardProvider: Error creating deck: $e");
      _error = e.toString();
      notifyListeners();
      print("FlashcardProvider: Notified listeners after error in createDeck");
    }
  }

  Future<void> deleteDeck(int index) async {
    if (_auth.currentUser == null) {
      print("FlashcardProvider: No user logged in, skipping deleteDeck");
      return;
    }

    if (index < 0 || index >= _decks.length) {
      print("FlashcardProvider: Tried to delete deck with invalid index $index");
      return;
    }

    print("FlashcardProvider: Deleting deck at index $index");
    try {
      final deckId = _decks[index]['id'];
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('decks')
          .doc(deckId)
          .delete();

      print("FlashcardProvider: Deleted deck from Firestore");
      _decks.removeAt(index);
      notifyListeners();
      print("FlashcardProvider: Notified listeners after deleting deck");
    } catch (e) {
      print("FlashcardProvider: Error deleting deck: $e");
      _error = e.toString();
      notifyListeners();
      print("FlashcardProvider: Notified listeners after error in deleteDeck");
    }
  }

  Future<void> addFlashcard(int deckIndex, String question, String answer) async {
    if (_auth.currentUser == null) {
      print("FlashcardProvider: No user logged in, skipping addFlashcard");
      return;
    }

    print("FlashcardProvider: Adding flashcard to deck at index $deckIndex");
    try {
      final deckId = _decks[deckIndex]['id'];
      final newFlashcard = {'question': question, 'answer': answer};

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('decks')
          .doc(deckId)
          .update({
        'flashcards': FieldValue.arrayUnion([newFlashcard])
      });

      print("FlashcardProvider: Added flashcard to Firestore");
      _decks[deckIndex]['flashcards'].add(
        Flashcard(question: question, answer: answer),
      );

      notifyListeners();
      print("FlashcardProvider: Notified listeners after adding flashcard");
    } catch (e) {
      print("FlashcardProvider: Error adding flashcard: $e");
      _error = e.toString();
      notifyListeners();
      print("FlashcardProvider: Notified listeners after error in addFlashcard");
    }
  }

  Future<void> deleteFlashcard(int deckIndex, int cardIndex) async {
    if (_auth.currentUser == null) {
      print("FlashcardProvider: No user logged in, skipping deleteFlashcard");
      return;
    }

    if (deckIndex < 0 || deckIndex >= _decks.length) {
      print("FlashcardProvider: Tried to delete flashcard with invalid deckIndex $deckIndex");
      return;
    }
    if (cardIndex < 0 || cardIndex >= _decks[deckIndex]['flashcards'].length) {
      print("FlashcardProvider: Tried to delete flashcard with invalid cardIndex $cardIndex");
      return;
    }

    print("FlashcardProvider: Deleting flashcard at deck $deckIndex, card $cardIndex");
    try {
      final deckId = _decks[deckIndex]['id'];
      final cardToDelete = _decks[deckIndex]['flashcards'][cardIndex];

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('decks')
          .doc(deckId)
          .update({
        'flashcards': FieldValue.arrayRemove([
          {'question': cardToDelete.question, 'answer': cardToDelete.answer}
        ])
      });

      print("FlashcardProvider: Deleted flashcard from Firestore");
      _decks[deckIndex]['flashcards'].removeAt(cardIndex);
      notifyListeners();
      print("FlashcardProvider: Notified listeners after deleting flashcard");
    } catch (e) {
      print("FlashcardProvider: Error deleting flashcard: $e");
      _error = e.toString();
      notifyListeners();
      print("FlashcardProvider: Notified listeners after error in deleteFlashcard");
    }
  }
} 