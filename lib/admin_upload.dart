import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUploadScreen extends StatelessWidget {
  const AdminUploadScreen({super.key});

  Future<void> uploadData(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final dataStr = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> data = jsonDecode(dataStr);

      final decksRef = firestore.collection('artifacts')
          .doc('smart-learn-v1')
          .collection('public')
          .doc('data')
          .collection('official_decks');

      final cardsRef = firestore.collection('artifacts')
          .doc('smart-learn-v1')
          .collection('public')
          .doc('data')
          .collection('official_cards');

      // Loop through subjects
      for (var subject in data.keys) {
        // Create deck
        final deckDoc = await decksRef.add({'name': subject});
        final deckId = deckDoc.id;

        // Create cards
        final batch = firestore.batch();
        for (var q in data[subject]) {
          final cardDoc = cardsRef.doc();
          batch.set(cardDoc, {
            'deckId': deckId,
            'question': q['question'],
            'answer': q['answer'],
          });
        }
        await batch.commit();
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Upload')),
      body: Center(
        child: ElevatedButton(
          child: const Text('UPLOAD QUESTIONS'),
          onPressed: () => uploadData(context),
        ),
      ),
    );
  }
}
