import 'package:flutter/material.dart';
import 'tabs/student_home.dart';
import 'tabs/student_learn.dart';
import 'tabs/student_progress.dart';
import 'tabs/student_profile.dart';

class StudentMainWrapper extends StatefulWidget {
  const StudentMainWrapper({super.key});
  @override
  State<StudentMainWrapper> createState() => _StudentMainWrapperState();
}

class _StudentMainWrapperState extends State<StudentMainWrapper> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const StudentHomeTab(),
    const StudentLearnTab(),
    const StudentProgressTab(),
    const StudentProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to go behind the navbar if we want a floating look
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent, // Handled by Container
          selectedItemColor: const Color(0xFFC490FF),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Learn"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Stats"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
