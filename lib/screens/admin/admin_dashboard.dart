import 'package:flutter/material.dart';
import 'tabs/admin_dash.dart';
import 'tabs/admin_content.dart';
import 'tabs/admin_analytics.dart';
import 'tabs/admin_profile.dart';

class AdminMainWrapper extends StatefulWidget {
  const AdminMainWrapper({super.key});
  @override
  State<AdminMainWrapper> createState() => _AdminMainWrapperState();
}

class _AdminMainWrapperState extends State<AdminMainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [const AdminDashTab(), const AdminContentTab(), const AdminAnalyticsTab(), const AdminProfileTab()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Content"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "System"),
        ],
      ),
    );
  }
}
