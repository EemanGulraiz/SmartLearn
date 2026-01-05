import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AppUser? _currentUser;
  bool _isInitializing = true;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isInitializing => _isInitializing;
  String? get error => _error;

  AuthService() { _init(); }

  Future<void> _init() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        final doc = await _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').doc(user.uid).collection('profile').doc('metadata').get();
        final data = doc.data();
        _currentUser = AppUser(
          uid: user.uid,
          firstName: data?['firstName'] ?? 'Student',
          lastName: data?['lastName'] ?? '',
          role: data?['role'] ?? 'user',
          semester: data?['semester'] ?? '1',
          points: data?['points'] ?? 0,
          streak: data?['streak'] ?? 0,
          totalMinutesStudied: data?['totalMinutesStudied'] ?? 0,
          weeklyGoalMinutes: data?['weeklyGoalMinutes'] ?? 600,
        );
      } else {
        _currentUser = null;
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  void setError(String? msg) => { _error = msg, notifyListeners() };

  Future<void> login(String email, String pass) async {
    try { _error = null; notifyListeners(); await _auth.signInWithEmailAndPassword(email: email, password: pass); }
    catch (e) { _error = e.toString(); notifyListeners(); }
  }

  Future<void> register(String email, String pass, String f, String l, String sem) async {
    try {
      _error = null; notifyListeners();
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').doc(cred.user!.uid).collection('profile').doc('metadata').set({
        'firstName': f,
        'lastName': l,
        'role': 'user',
        'semester': sem,
        'email': email,
        'points': 0,
        'streak': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _error = "Registration successful! Please login."; await _auth.signOut(); notifyListeners();
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) { setError("Please enter your email."); return; }
    try {
      _error = null; notifyListeners();
      await _auth.sendPasswordResetEmail(email: email);
      _error = "Password reset link sent to your email!"; notifyListeners();
    } catch (e) { _error = e.toString(); notifyListeners(); }
  }

  Future<void> updateProfile(String f, String l, String sem) async {
    if (_currentUser == null) return;
    try {
      await _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').doc(_currentUser!.uid).collection('profile').doc('metadata').update({
        'firstName': f,
        'lastName': l,
        'semester': sem,
      });
      _init();
      notifyListeners();
    } catch (e) { setError(e.toString()); }
  }

  void logout() => _auth.signOut();

  Future<void> addPoints(int p) async {
    if (_currentUser == null) return;
    final newPoints = (_currentUser!.points) + p;
    await _db.collection('artifacts').doc(AppConstants.appIdEnv).collection('users').doc(_currentUser!.uid).collection('profile').doc('metadata').update({'points': newPoints});
    _init();
  }
}
