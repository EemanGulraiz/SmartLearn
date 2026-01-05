import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deck_model.dart';
import '../config/constants.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _public(String col) => _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('public').doc('data').collection(col);
  CollectionReference _user(String uid, String col) => _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').doc(uid).collection(col);

  Stream<List<Deck>> watchDecks() => _public('official_decks').snapshots().map((s) => s.docs.map((d) => Deck.fromFirestore(d)).toList());
  Stream<List<Flashcard>> watchCards(String deckId) => _public('official_cards').snapshots().map((s) {
    final all = s.docs.map((d) => Flashcard.fromFirestore(d)).toList();
    return all.where((c) => c.deckId == deckId).toList();
  });

  Future<void> toggleBookmark(String uid, String cardId) async {
    final doc = _user(uid, 'bookmarks').doc(cardId);
    final exists = await doc.get();
    exists.exists ? await doc.delete() : await doc.set({'bookmarkedAt': FieldValue.serverTimestamp()});
  }

  Stream<List<String>> watchBookmarks(String uid) => _user(uid, 'bookmarks').snapshots().map((s) => s.docs.map((d) => d.id).toList());
  Stream<List<String>> watchMastered(String uid) => _user(uid, 'mastery').snapshots().map((s) => s.docs.map((d) => d.id).toList());

  Future<void> markMastered(String uid, String cardId) async {
    await _user(uid, 'mastery').doc(cardId).set({'masteredAt': FieldValue.serverTimestamp()});
  }

  Future<void> saveQuizResult(String uid, String deckName, int score, int total) async {
    await _public('quiz_history').add({'uid': uid, 'deckName': deckName, 'score': score, 'total': total, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> watchHistory(String uid) => _public('quiz_history').snapshots();
  Stream<QuerySnapshot> watchGlobalHistory() => _public('quiz_history').snapshots();

  // Leaderboard
  Stream<List<Map<String, dynamic>>> watchLeaderboard() {
    return _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> users = [];
      for (var doc in snapshot.docs) {
        final profile = await doc.reference.collection('profile').doc('metadata').get();
        if (profile.exists) {
          final data = profile.data()!;
          users.add({
            'uid': doc.id,
            'name': "${data['firstName']} ${data['lastName']}",
            'points': data['points'] ?? 0,
            'semester': data['semester'] ?? '?',
            'role': data['role'] ?? 'user' // To filter out admins if needed
          });
        }
      }
      users.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
      return users.take(10).toList();
    });
  }

  // Admin Ops
  Future<void> addDeck(String n, String i, String sem) => _public('official_decks').add({'name': n, 'imageUrl': i, 'semester': sem});
  Future<void> updateDeck(String id, String n, String i, String sem) => _public('official_decks').doc(id).update({'name': n, 'imageUrl': i, 'semester': sem});
  Future<void> deleteDeck(String id) => _public('official_decks').doc(id).delete();
  Future<void> addCard(String dId, String q, String a, String diff) => _public('official_cards').add({'deckId': dId, 'question': q, 'answer': a, 'difficulty': diff});
  Future<void> updateStudyTime(String uid, int minutes) async {
    final doc = _user(uid, 'profile').doc('metadata');
    // Using SetOptions(merge: true) implicitly via set or update if exists
    // But since we are incrementing, we need FieldValue.increment
    await doc.update({
      'totalMinutesStudied': FieldValue.increment(minutes),
      'lastStudyDate': FieldValue.serverTimestamp() // Could track streaks here too
    });
  }

  Future<void> deleteCard(String id) => _public('official_cards').doc(id).delete();
}
