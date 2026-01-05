import 'package:flutter/material.dart';
import '../../models/deck_model.dart';
import '../../services/db_service.dart';
import '../../screens/shared/study_session.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final DBService db;
  final String uid;
  final VoidCallback? onTap;

  const DeckCard({
    super.key,
    required this.deck,
    required this.db,
    required this.uid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Flashcard>>(
        stream: db.watchCards(deck.id),
        builder: (context, cardSnap) {
          final allCards = cardSnap.data ?? [];
          return StreamBuilder<List<String>>(
              stream: db.watchMastered(uid),
              builder: (context, masterySnap) {
                final masteredIds = masterySnap.data ?? [];
                final deckMastered = allCards.where((c) => masteredIds.contains(c.id)).length;
                final progress = allCards.isEmpty ? 0.0 : deckMastered / allCards.length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    color: const Color(0xFF2A2D3E), // Dark card background
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudySession(deck: deck))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Hero Image
                            Hero(
                              tag: 'deck-${deck.id}',
                              child: Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  image: DecorationImage(
                                    image: NetworkImage(deck.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (e, s) {}, 
                                  ),
                                  color: Colors.white10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deck.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.indigoAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Text(
                                      "Semester ${deck.semester}",
                                      style: const TextStyle(color: Colors.indigoAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white10,
                                      color: progress == 1.0 ? Colors.greenAccent : const Color(0xFFC490FF),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${(progress * 100).toInt()}% Mastered • ${allCards.length} Cards",
                                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Action Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle
                              ),
                              child: Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey[300]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
