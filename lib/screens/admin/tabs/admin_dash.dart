import 'package:flutter/material.dart';

class AdminDashTab extends StatelessWidget {
  const AdminDashTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 40, 20, 20),
          children: [
            const Text("System Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            _adminStatCard("Total Students", "Connected", Icons.people, const Color(0xFFC490FF)),
            _adminStatCard("Active Subjects", "Live", Icons.subject, Colors.indigoAccent),
            _adminStatCard("Total Questions", "Verified", Icons.quiz, Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _adminStatCard(String l, String v, IconData i, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(i, color: c, size: 28),
        ),
        title: Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(v, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
