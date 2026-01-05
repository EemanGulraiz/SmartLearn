import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../models/deck_model.dart';
import 'study_session.dart';
import 'quiz_session.dart';
import '../../widgets/deck_card.dart';

class DeckListScreen extends StatelessWidget {
  final String mode;
  const DeckListScreen({super.key, required this.mode});
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    final user = Provider.of<AuthService>(context, listen: false).currentUser!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Select Subject for $mode", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          )
        ),
        child: StreamBuilder<List<Deck>>(
          stream: db.watchDecks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final allDecks = snapshot.data!;
            final decks = allDecks.where((d) => d.semester == user.semester || d.semester == 'All').toList();

            return ListView.builder(
              itemCount: decks.length,
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 16),
              itemBuilder: (context, i) => DeckCard(
                deck: decks[i],
                db: db,
                uid: user.uid,
                onTap: () {
                  if (mode == 'study') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => StudySession(deck: decks[i])));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizSession(deck: decks[i], isMock: mode == 'mock')));
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
