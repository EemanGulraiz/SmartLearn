import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/db_service.dart';
import '../../../models/deck_model.dart';
import '../../shared/study_session.dart';
import '../../../widgets/deck_card.dart';

class StudentLearnTab extends StatefulWidget {
  const StudentLearnTab({super.key});

  @override
  State<StudentLearnTab> createState() => _StudentLearnTabState();
}

class _StudentLearnTabState extends State<StudentLearnTab> {
  // Initialize with 'All' or user's semester if we had access to it directly in initState,
  // but we'll deal with defaults in the build method.
  String _selectedSemester = 'All'; 
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    final user = Provider.of<AuthService>(context).currentUser!;

    // One-time initialization to set the filter to the user's semester
    if (!_initialized) {
      _selectedSemester = user.semester;
      _initialized = true;
    }

    final semesters = ['All', '1', '2', '3', '4', '5', '6', '7', '8'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Subject Library", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          )
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
            // --- Semester Selector ---
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: semesters.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sem = semesters[i];
                final isSelected = _selectedSemester == sem;
                return ChoiceChip(
                  label: Text(sem == 'All' ? 'All' : 'Sem $sem'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFC490FF),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  side: BorderSide(color: isSelected ? Colors.transparent : Colors.white12),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedSemester = sem);
                  },
                );
              },
            ),
          ),
          
          // --- Content Area ---
          Expanded(
            child: StreamBuilder<List<Deck>>(
              stream: db.watchDecks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allDecks = snapshot.data!;
                // Filter Logic:
                // If 'All' is selected, show everything.
                // Otherwise, match exact semester OR 'All' (global subjects).
                final filteredDecks = allDecks.where((d) {
                  if (_selectedSemester == 'All') return true;
                  return d.semester == _selectedSemester || d.semester == 'All';
                }).toList();

                if (filteredDecks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No subjects found for Semester $_selectedSemester", 
                          style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDecks.length,
                  itemBuilder: (context, i) {
                    return _buildDeckCard(context, filteredDecks[i], db, user.uid);
                  },
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, Deck deck, DBService db, String uid) {
    return DeckCard(deck: deck, db: db, uid: uid);
  }
}
