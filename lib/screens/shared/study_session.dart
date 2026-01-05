import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deck_model.dart';
import '../../services/db_service.dart';

class StudySession extends StatefulWidget {
  final Deck deck;
  const StudySession({super.key, required this.deck});
  @override
  State<StudySession> createState() => _StudySessionState();
}

class _StudySessionState extends State<StudySession> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  
  void _nextCard(int total) {
    if (_currentIndex < total - 1) {
      setState(() { _currentIndex++; _isFlipped = false; });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() { _currentIndex--; _isFlipped = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _iconBtn(Icons.arrow_back, () => Navigator.pop(context)),
        title: const Text("Lesson Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [_iconBtn(Icons.share, () {})],
      ),
      body: StreamBuilder<List<Flashcard>>(
        stream: db.watchCards(widget.deck.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snapshot.data!;
          
          if (cards.isEmpty) return _emptyView();

          return Column(
            children: [
              // --- Interactive Header (Premium) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 100, bottom: 40, left: 24, right: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF8E54E9), const Color(0xFF4776E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF4776E6).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  children: [
                    // Centered Deck Image
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(widget.deck.imageUrl),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("Mastering ${widget.deck.name}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Text("Beginner Level", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // --- Stats Row ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem(Icons.copy_all_rounded, "${cards.length}", "Cards", Colors.blueAccent),
                    _statItem(Icons.quiz_rounded, "${(cards.length / 5).ceil()}", "Quizzes", Colors.orangeAccent),
                    _statItem(Icons.timer_rounded, "5.0", "Hours", Colors.purpleAccent),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Current Card: ${_currentIndex + 1}/${cards.length}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                          Text("Progress: ${((_currentIndex + 1) / cards.length * 100).toInt()}%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Card Display
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 200),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2D3E),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Q: ${cards[_currentIndex].question}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4), textAlign: TextAlign.center),
                            const SizedBox(height: 30),
                            if (_isFlipped) 
                              Text("A: ${cards[_currentIndex].answer}", style: const TextStyle(fontSize: 18, color: Color(0xFF8E54E9), fontWeight: FontWeight.w500), textAlign: TextAlign.center)
                            else
                              TextButton.icon(
                                onPressed: () => setState(() => _isFlipped = true), 
                                icon: const Icon(Icons.touch_app_rounded),
                                label: const Text("Tap to Reveal Answer")
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Navigation
                       SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4776E6),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFF4776E6).withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () {
                            if (_currentIndex < cards.length - 1) _nextCard(cards.length);
                            else Navigator.pop(context); // Finish
                          },
                          child: Text(_currentIndex < cards.length - 1 ? "Next Card" : "Finish Lesson", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyView() => Scaffold(appBar: AppBar(), body: const Center(child: Text("No cards yet!")));

  Widget _iconBtn(IconData i, VoidCallback cb) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: cb,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(i, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _statItem(IconData i, String val, String label, Color tint) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: tint.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(i, color: tint, size: 24),
          ),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
