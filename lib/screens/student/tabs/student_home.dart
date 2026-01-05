import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../shared/deck_list_screen.dart';

class StudentHomeTab extends StatelessWidget {
  const StudentHomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser!;
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100), // Padding for nav bar
          child: Column(
            children: [
              // --- Custom Header ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2A2D3E), const Color(0xFF212436)], // Subtle contrast for header
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(user.firstName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC490FF), width: 2), shape: BoxShape.circle),
                          child: const CircleAvatar(radius: 20, backgroundColor: Colors.transparent, child: Icon(Icons.person, color: Colors.white)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Small Stats Row inside Header
                    Row(
                      children: [
                        _miniStat(Icons.stars_rounded, "${user.points} XP", Colors.amber),
                        const SizedBox(width: 12),
                        _miniStat(Icons.local_fire_department_rounded, "${user.streak} Day Streak", Colors.orangeAccent),
                      ],
                    )
                  ],
                ),
              ),

              // --- Daily Quote ---
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D3E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Daily Wisdom", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white54)),
                            SizedBox(height: 4),
                            Text(
                              "\"The beautiful thing about learning is that no one can take it away from you.\"",
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Body ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    
                    _bigActionCard(
                      context, 
                      "Study Mode", "Master your flashcards", 
                      Icons.school_rounded, 
                      const Color(0xFFC490FF), 
                      const DeckListScreen(mode: 'study')
                    ),
                    const SizedBox(height: 30),
                    
                    // --- Assessment Zone ---
                    const Text("Assessment Zone", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    
                    _actionCard(context, "Practice Quiz", "Quick refresher", Icons.flash_on_rounded, Colors.amber, const DeckListScreen(mode: 'quiz')),
                    _actionCard(context, "Adaptive Quiz", "Dynamic difficulty", Icons.psychology_rounded, Colors.cyanAccent, const DeckListScreen(mode: 'quiz')),
                    _actionCard(context, "Full Mock Exam", "Timed simulation", Icons.timer_rounded, Colors.redAccent, const DeckListScreen(mode: 'mock')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _bigActionCard(BuildContext context, String t, String s, IconData i, Color c, Widget target) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3E), // Darker surface
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(i, color: c, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(s, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ]),
      ),
    );
  }
  
  Widget _actionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget target) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    if(subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
