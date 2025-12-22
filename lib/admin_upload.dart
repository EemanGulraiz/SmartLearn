import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String appId = 'smart-learn-v1';

Future<void> uploadAllSubjectsAndQuestions() async {
  final firestore = FirebaseFirestore.instance;

  // 1️⃣ Load JSON
  final jsonString =
  await rootBundle.loadString('assets/questions.json');
  final Map<String, dynamic> data = jsonDecode(jsonString);

  // Firestore paths (MATCHING YOUR APP)
  final decksRef = firestore
      .collection('artifacts')
      .doc(appId)
      .collection('public')
      .doc('data')
      .collection('official_decks');

  final cardsRef = firestore
      .collection('artifacts')
      .doc(appId)
      .collection('public')
      .doc('data')
      .collection('official_cards');

  // 2️⃣ Loop subjects
  for (String subject in data.keys) {
    // Create deck
    final deckDoc = await decksRef.add({
      'name': subject,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final deckId = deckDoc.id;

    // 3️⃣ Batch upload questions
    WriteBatch batch = firestore.batch();
    for (var q in data[subject]) {
      final doc = cardsRef.doc();
      batch.set(doc, {
        'deckId': deckId,
        'question': q['question'],
        'answer': q['answer'],
      });
    }

    await batch.commit();
  }

  print("✅ Subjects & questions uploaded successfully");
}
