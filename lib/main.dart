import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'admin_upload.dart';

// --- GLOBAL FIREBASE CONFIGURATION ---
const String _appIdEnv = String.fromEnvironment('appId', defaultValue: 'smart-learn-v1');
const String _firebaseConfigStr = String.fromEnvironment(
    'firebaseConfig',
    defaultValue: '{"apiKey": "AIzaSyBcdIHRdsN_CmiibGv59PGgqXSNM0CossA", "authDomain": "smart-learn-app-b3843.firebaseapp.com", "projectId": "smart-learn-app-b3843", "storageBucket": "smart-learn-app-b3843.firebasestorage.app", "messagingSenderId": "1072911140026"}'
);

// --- MODELS ---
class AppUser {
  final String uid;
  final String firstName;
  AppUser({required this.uid, required this.firstName});
}

class Deck {
  final String id;
  final String name;

  Deck({required this.id, required this.name});

  static Deck fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    // RESILIENT FETCHING: Checks for almost any possible name you might have used in Firebase
    String fetchedName = data?['name'] ??
        data?['Name'] ??
        data?['title'] ??
        data?['subject'] ??
        data?['subject_name'] ??
        data?['deck_name'] ??
        'Untitled Subject';
    return Deck(id: doc.id, name: fetchedName);
  }
}

class Flashcard {
  final String id;
  final String deckId;
  final String question;
  final String answer;

  Flashcard({required this.id, required this.deckId, required this.question, required this.answer});

  static Flashcard fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Flashcard(
      id: doc.id,
      deckId: data?['deckId'] ?? '',
      question: data?['question'] ?? data?['Question'] ?? 'No Question',
      answer: data?['answer'] ?? data?['Answer'] ?? 'No Answer',
    );
  }
}

// --- SERVICES ---
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AppUser? _currentUser;
  bool _isInitializing = true;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  AuthService() { _init(); }

  Future<void> _init() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final doc = await _db.collection('artifacts').doc(_appIdEnv).collection('users').doc(user.uid).collection('profile').doc('metadata').get();
          _currentUser = AppUser(uid: user.uid, firstName: doc.data()?['firstName'] ?? 'Student');
        } catch (e) {
          _currentUser = AppUser(uid: user.uid, firstName: 'Student');
        }
      } else {
        _currentUser = null;
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String pass) async {
    try {
      _error = null;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  Future<void> register(String email, String pass, String f, String l) async {
    try {
      _error = null;
      notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await _db.collection('artifacts').doc(_appIdEnv).collection('users').doc(cred.user!.uid).collection('profile').doc('metadata').set({
        'firstName': f, 'lastName': l, 'role': 'user', 'email': email, 'createdAt': FieldValue.serverTimestamp(),
      });
      await _auth.signOut();
      _error = "Account created! You can now log in.";
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  void logout() => _auth.signOut();
}

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _public(String col) =>
      _db.collection('artifacts').doc(_appIdEnv).collection('public').doc('data').collection(col);

  Stream<List<Deck>> watchDecks() {
    return _public('official_decks').snapshots().map((s) => s.docs.map((d) => Deck.fromFirestore(d)).toList());
  }

  Stream<List<Flashcard>> watchCards(String deckId) {
    return _public('official_cards').snapshots().map((s) {
      final all = s.docs.map((d) => Flashcard.fromFirestore(d)).toList();
      return all.where((c) => c.deckId == deckId).toList();
    });
  }

}

// --- UI COMPONENTS ---

class FlipCardWidget extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCardWidget({super.key, required this.front, required this.back});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double angle = _animation.value * pi;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: angle < pi / 2
                ? widget.front
                : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(pi),
              child: widget.back,
            ),
          );
        },
      ),
    );
  }
}

// --- SCREENS ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final e = TextEditingController();
  final p = TextEditingController();
  final f = TextEditingController();
  final l = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(30), child: Column(children: [
        const Icon(Icons.auto_stories, size: 80, color: Colors.indigo),
        const SizedBox(height: 10),
        const Text("SmartLearn", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const Text("School Revision System", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        if (!isLogin) ...[
          TextField(controller: f, decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: l, decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder())),
          const SizedBox(height: 10),
        ],
        TextField(controller: e, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: p, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 20),
        if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () => isLogin ? auth.login(e.text, p.text) : auth.register(e.text, p.text, f.text, l.text),
            child: Text(isLogin ? "LOGIN" : "SIGN UP"),
          ),
        ),
        TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? "Need an account? Sign Up" : "Have an account? Login")),
      ]))),
    );
  }
}

class DeckListScreen extends StatelessWidget {
  const DeckListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<DBService>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text("Welcome, ${auth.currentUser?.firstName}"),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: auth.logout)],
      ),
      body: StreamBuilder<List<Deck>>(
        stream: db.watchDecks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final decks = snapshot.data!;
          if (decks.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.library_books, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Library is empty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Admin hasn't added subjects yet."),
            ]));
          }

          return ListView.builder(
            itemCount: decks.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, i) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(decks[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: const Text("Tap to view flashcards & quiz"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.indigo),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudyScreen(deck: decks[i]))),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StudyScreen extends StatefulWidget {
  final Deck deck;
  const StudyScreen({super.key, required this.deck});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int idx = 0;
  bool isQuiz = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DBService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(widget.deck.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(isQuiz ? "QUIZ MODE" : "STUDY MODE"),
              selected: isQuiz,
              onSelected: (val) => setState(() => isQuiz = val),
              selectedColor: Colors.white,
              labelStyle: TextStyle(color: isQuiz ? Colors.indigo : Colors.white),
              backgroundColor: Colors.indigo[400],
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Flashcard>>(
        stream: db.watchCards(widget.deck.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snapshot.data!;
          if (cards.isEmpty) return const Center(child: Text("No questions added for this subject."));

          if (idx >= cards.length) idx = 0;
          final card = cards[idx];

          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Topic ${idx + 1} of ${cards.length}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            if (!isQuiz)
              Center(
                child: FlipCardWidget(
                  front: _face(card.question, Colors.indigo),
                  back: _face(card.answer, Colors.teal),
                ),
              )
            else
              _quizView(card, cards),
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: idx > 0 ? () => setState(() => idx--) : null),
              const SizedBox(width: 80),
              IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: idx < cards.length - 1 ? () => setState(() => idx++) : null),
            ])
          ]);
        },
      ),
    );
  }



  Widget _quizView(Flashcard c, List<Flashcard> all) {
    final opts = [c.answer];
    final dist = all.where((x) => x.id != c.id).map((x) => x.answer).toList()..shuffle();
    opts.addAll(dist.take(3));
    opts.shuffle();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(children: [
        Text(c.question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 30),
        ...opts.map((o) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                bool isCorrect = o == c.answer;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isCorrect ? "Correct!" : "Oops! Incorrect."),
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                    duration: const Duration(milliseconds: 600)
                ));
              },
              child: Text(o)
          ),
        ))),
      ]),
    );
  }

  Widget _face(String text, Color color) => Container(
    width: 320,
    height: 220,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
    ),
    alignment: Alignment.center,
    padding: const EdgeInsets.all(24),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}


// --- APP ENTRY ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = jsonDecode(_firebaseConfigStr);
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config['apiKey'] ?? '',
      appId: _appIdEnv,
      messagingSenderId: config['messagingSenderId'] ?? '',
      projectId: config['projectId'] ?? '',
      storageBucket: config['storageBucket'] ?? '',
    ),
  );



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DBService()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Root(),
      ),
    ),
  );
}



class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (auth.isInitializing) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return auth.isAuthenticated ? const DeckListScreen() : const AuthScreen();
  }
}