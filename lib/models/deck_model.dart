import 'package:cloud_firestore/cloud_firestore.dart';

class Deck {
  final String id;
  final String name;
  final String imageUrl;
  final String semester;
  Deck({required this.id, required this.name, required this.imageUrl, required this.semester});

  static Deck fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Deck(
      id: doc.id,
      name: data?['name'] ?? 'Untitled Subject',
      imageUrl: data?['imageUrl'] ?? 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80',
      semester: data?['semester'] ?? 'All',
    );
  }
}

class Flashcard {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final String difficulty;

  Flashcard({required this.id, required this.deckId, required this.question, required this.answer, required this.difficulty});

  static Flashcard fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Flashcard(
      id: doc.id,
      deckId: data?['deckId'] ?? '',
      question: data?['question'] ?? 'No Question',
      answer: data?['answer'] ?? 'No Answer',
      difficulty: data?['difficulty'] ?? 'Beginner',
    );
  }
}
