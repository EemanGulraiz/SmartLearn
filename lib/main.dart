import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/db_service.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

// --- ROOT & ENTRY POINT ---

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    if (auth.isInitializing) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!auth.isAuthenticated) return const AuthScreen();
    return auth.isAdmin ? const AdminMainWrapper() : const StudentMainWrapper();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final config = jsonDecode(AppConstants.firebaseConfigStr);
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: config['apiKey'], appId: AppConstants.appIdEnv, messagingSenderId: config['messagingSenderId'], projectId: config['projectId'], storageBucket: config['storageBucket']));
  } catch (e) {
    // Fallback if environment variable config fails or not present, try default platform options if available
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) => AuthService()), Provider(create: (_) => DBService())], child: MaterialApp(
    title: 'Smart Learn', 
    debugShowCheckedModeBanner: false, 
    theme: AppTheme.darkTheme, 
    home: const Root()
  )));
}