import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Profile")),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Center(child: Column(children: [
          CircleAvatar(radius: 50, backgroundColor: Colors.redAccent, child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white)),
          SizedBox(height: 10),
          Text("System Administrator", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: auth.logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text("LOGOUT ADMIN SESSION")),
      ]),
    );
  }
}
