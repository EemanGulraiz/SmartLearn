import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/db_service.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Global Performance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: db.watchGlobalHistory(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            return ListView(padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 40, 20, 20), children: [
              Text("Total Quizzes Attempted: ${docs.length}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              
              const Text("Performance Insights", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 10),
              
              // Stats Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Row(
                  children: [
                     Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.analytics, color: Colors.white)),
                     const SizedBox(width: 15),
                     Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       const Text("Total Quizzes", style: TextStyle(color: Colors.white70)),
                       Text("${docs.length}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                     ])
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Container(
                 decoration: BoxDecoration(
                   color: const Color(0xFF2A2D3E),
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                 ),
                 child: ListTile(
                   leading: Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                     child: const Icon(Icons.sync, color: Colors.blueAccent),
                   ),
                   title: const Text("Global Score Aggregation", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
                   subtitle: const Text("Syncing results from all registered students.", style: TextStyle(color: Colors.white54, fontSize: 12)), 
                 ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
