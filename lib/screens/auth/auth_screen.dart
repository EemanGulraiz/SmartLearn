import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailC = TextEditingController();
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Reset Password"), backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: Padding(padding: const EdgeInsets.all(30.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            child: const Icon(Icons.lock_reset, size: 60, color: Color(0xFFC490FF)),
          ),
          const SizedBox(height: 20),
          const Text("Enter your email to receive a password reset link.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: TextField(controller: emailC, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Email Address", border: InputBorder.none, labelStyle: TextStyle(color: Colors.white54))),
          ),
          const SizedBox(height: 20),
          if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC490FF), foregroundColor: Colors.white), onPressed: () => auth.resetPassword(emailC.text.trim()), child: const Text("SEND RESET LINK"))),
        ])),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final e = TextEditingController(); final p = TextEditingController();
  final f = TextEditingController(); final l = TextEditingController();
  String selectedSemester = '1';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Logo Wrapper
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                  child: const Icon(Icons.school_rounded, size: 60, color: Color(0xFFC490FF)),
                ),
                const SizedBox(height: 24),
                const Text("SmartLearn", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text("Adaptive University Learning", style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 40),
                
                // Fields Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D3E),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)]
                  ),
                  child: Column(
                    children: [
                      if (!isLogin) ...[
                        _authField(f, "First Name", false),
                        const SizedBox(height: 12),
                        _authField(l, "Last Name", false),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                          child: DropdownButtonFormField<String>(
                            value: selectedSemester,
                            dropdownColor: const Color(0xFF2A2D3E),
                            items: ['1','2','3','4','5','6','7','8'].map((s) => DropdownMenuItem(value: s, child: Text("Semester $s", style: const TextStyle(color: Colors.white)))).toList(),
                            onChanged: (v) => setState(() => selectedSemester = v!),
                            decoration: const InputDecoration(labelText: "Semester", border: InputBorder.none, labelStyle: TextStyle(color: Colors.white54)),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _authField(e, "Email", false),
                      const SizedBox(height: 12),
                      _authField(p, "Password", true),
                    ],
                  ),
                ),

                if (isLogin) Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        auth.setError(null);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                      },
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFFC490FF)))
                  ),
                ),
                
                const SizedBox(height: 24),
                if (auth.error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(auth.error!, style: const TextStyle(color: Colors.redAccent))),
                
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC490FF), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  onPressed: () {
                    if (!isLogin) {
                      // Validate First Name
                      if (f.text.isEmpty || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(f.text) || !RegExp(r'[a-zA-Z]').hasMatch(f.text)) {
                        auth.setError("First Name must be alphanumeric and contain at least one letter.");
                        return;
                      }
                      // Validate Last Name
                      if (l.text.isEmpty || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(l.text) || !RegExp(r'[a-zA-Z]').hasMatch(l.text)) {
                        auth.setError("Last Name must be alphanumeric and contain at least one letter.");
                        return;
                      }
                      // Validate Email
                      if (e.text.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e.text)) {
                        auth.setError("Please enter a valid email address.");
                        return;
                      }
                      // Validate Password
                      if (p.text.length < 6 || !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(p.text)) {
                        auth.setError("Password must be at least 6 chars with letters & numbers.");
                        return;
                      }
                    }
                    isLogin ? auth.login(e.text, p.text) : auth.register(e.text, p.text, f.text, l.text, selectedSemester);
                  },
                  child: Text(isLogin ? "LOGIN" : "CREATE ACCOUNT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin), 
                  child: Text(isLogin ? "Join SmartLearn Today" : "Already have an account? Login", style: const TextStyle(color: Colors.white70))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _authField(TextEditingController c, String label, bool obscure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: c, 
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label, border: InputBorder.none, labelStyle: const TextStyle(color: Colors.white54))
      ),
    );
  }
}
