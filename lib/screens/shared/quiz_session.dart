import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../models/deck_model.dart';
import '../../models/user_model.dart'; // Implicitly needed for logic sometimes but stricter

class QuizSession extends StatefulWidget {
  final Deck deck; final bool isMock;
  const QuizSession({super.key, required this.deck, required this.isMock});
  @override
  State<QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<QuizSession> {
  int idx = 0; int score = 0; int timeLeft = 30; Timer? timer; bool finished = false;
  List<String> options = []; int lastIdx = -1;

  @override
  void initState() { super.initState(); timeLeft = widget.isMock ? 60 : 30; timer = Timer.periodic(const Duration(seconds: 1), (t) { if (timeLeft > 0) setState(() => timeLeft--); else _next(); }); }
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  void _next() { if (idx < 9) setState(() { idx++; options = []; timeLeft = widget.isMock ? 60 : 30; }); else setState(() => finished = true); }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    if (finished) {
      return Scaffold(
          body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            Text("Final Score: $score/10", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {
              db.saveQuizResult(auth.currentUser!.uid, widget.deck.name, score, 10);
              auth.addPoints(score * 5);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }, child: const Text("Return Home"))
          ]))
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.isMock ? "Mock Test" : "Practice Quiz"), bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: timeLeft / (widget.isMock ? 60 : 30)))),
      body: StreamBuilder<List<Flashcard>>(
          stream: db.watchCards(widget.deck.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final all = snapshot.data!; if (all.length < 5) return const Center(child: Text("Not enough questions in this deck."));
            final card = all[idx % all.length];
            if (options.isEmpty || lastIdx != idx) {
              final opts = [card.answer]; final dist = all.where((c) => c.id != card.id).map((c) => c.answer).toList()..shuffle();
              opts.addAll(dist.take(3)); opts.shuffle(); options = opts; lastIdx = idx;
            }
            return Padding(padding: const EdgeInsets.all(30), child: Column(children: [
              Text("Question ${idx+1}/10", style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              Text(card.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ...options.map((o) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 12), child: ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)), onPressed: () { if (o == card.answer) score++; _next(); }, child: Text(o)))),
              const Spacer(),
              Text("${timeLeft}s Remaining", style: TextStyle(color: timeLeft < 10 ? Colors.red : Colors.grey, fontWeight: FontWeight.bold)),
            ]));
          }
      ),
    );
  }
}
