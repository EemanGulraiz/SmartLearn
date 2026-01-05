import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/db_service.dart';
import '../../../models/deck_model.dart';
import '../../../config/theme.dart';

class AdminContentTab extends StatelessWidget {
  const AdminContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final semesters = ['All', '1', '2', '3', '4', '5', '6', '7', '8'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Semester Categories", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: semesters.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSemesterDetail(semester: semesters[index]))),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC490FF), Color(0xFF8E2DE2)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(2, 4))]
                ),
                alignment: Alignment.center,
                child: Text(
                  "Semester ${semesters[index]}",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AdminSemesterDetail extends StatelessWidget {
  final String semester;
  const AdminSemesterDetail({super.key, required this.semester});

  void _showAddSubject(BuildContext context, DBService db) {
    final nameCtrl = TextEditingController();
    final imgCtrl = TextEditingController(); // Could default to a placeholder
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),
        title: const Text("Add New Subject", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Subject Name", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
          TextField(controller: imgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Image URL (Optional)", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                db.addDeck(nameCtrl.text, imgCtrl.text.isNotEmpty ? imgCtrl.text : 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=500&q=80', semester);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC490FF)),
            child: const Text("Add", style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  void _showEditSubject(BuildContext context, DBService db, Deck deck) {
    final nameCtrl = TextEditingController(text: deck.name);
    final imgCtrl = TextEditingController(text: deck.imageUrl);
    final semCtrl = TextEditingController(text: deck.semester);

    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),
        title: const Text("Edit Subject", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Subject Name", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
          TextField(controller: imgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Image URL", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
          TextField(controller: semCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Semester", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                db.updateDeck(deck.id, nameCtrl.text, imgCtrl.text, semCtrl.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC490FF)),
            child: const Text("Save", style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }

  void _showAddCard(BuildContext context, DBService db, String deckId) {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    String diff = 'Medium';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2D3E),
          title: const Text("Add Flashcard", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: qCtrl, maxLines: 2, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Question", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
              const SizedBox(height: 8),
              TextField(controller: aCtrl, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Answer", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: diff,
                dropdownColor: const Color(0xFF2A2D3E),
                style: const TextStyle(color: Colors.white),
                items: ['Easy', 'Medium', 'Hard'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => diff = v!)
              )
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () {
                 if (qCtrl.text.isNotEmpty && aCtrl.text.isNotEmpty) {
                   db.addCard(deckId, qCtrl.text, aCtrl.text, diff);
                   Navigator.pop(ctx);
                 }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC490FF)),
              child: const Text("Save", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Sem $semester Subjects", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddSubject(context, db))]
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: StreamBuilder<List<Deck>>(
          stream: db.watchDecks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final decks = snapshot.data!.where((d) => semester == 'All' ? true : d.semester == semester).toList();
  
            if (decks.isEmpty) return const Center(child: Text("No subjects in this folder yet.", style: TextStyle(color: Colors.white54)));
  
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 16),
              itemCount: decks.length,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                  border: Border.all(color: Colors.white.withOpacity(0.05))
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(decks[i].imageUrl), fit: BoxFit.cover)),
                  ),
                  title: Text(decks[i].name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Semester ${decks[i].semester}", style: const TextStyle(color: Colors.white54)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(tooltip: "Edit Subject", icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () => _showEditSubject(context, db, decks[i])),
                    IconButton(tooltip: "Add Flashcard", icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC490FF)), onPressed: () => _showAddCard(context, db, decks[i].id)),
                    IconButton(tooltip: "Delete Subject", icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => db.deleteDeck(decks[i].id)),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
