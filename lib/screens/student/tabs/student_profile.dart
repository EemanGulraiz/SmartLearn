import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class StudentProfileTab extends StatelessWidget {
  const StudentProfileTab({super.key});

  // --- Redesigned Edit Profile Screen ---
  void _showEditDialog(BuildContext context, AuthService auth) {
    if (auth.currentUser == null) return;
    
    // We use a full screen Scaffold for the "Page" feel requested
    final fNameController = TextEditingController(text: auth.currentUser!.firstName);
    final lNameController = TextEditingController(text: auth.currentUser!.lastName);
    final emailController = TextEditingController(text: "student@example.com"); // Placeholder
    final semesterController = TextEditingController(text: auth.currentUser!.semester);
    
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E), // Match dark theme
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
             backgroundColor: Colors.transparent,
             elevation: 0,
             leading: IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.white),
               onPressed: () => Navigator.pop(context),
             ),
             title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
             centerTitle: true,
             actions: [
               IconButton(
                 icon: const Icon(Icons.check, color: Color(0xFF4AC3FF)), // Mint/Blue check color
                 onPressed: () {
                   auth.updateProfile(fNameController.text, lNameController.text, semesterController.text);
                   Navigator.pop(context);
                 },
               ),
               const SizedBox(width: 8),
             ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Profile Pic ---
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                        child: const CircleAvatar(radius: 60, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 60, color: Colors.white)),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- Fields ---
                _buildEditField("First Name", fNameController, false),
                _buildEditField("Last Name", lNameController, false),
                 _buildEditField("E-mail address", emailController, true), // Read only styling
                _buildEditField("Semester", semesterController, false),
                
                 const SizedBox(height: 10),
                 const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                 const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFF2A2D3E), borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: InputBorder.none, 
                        hintText: "••••••••", 
                        hintStyle: const TextStyle(color: Colors.white24),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        )
                    )
                  ),
                ),
                
                 const SizedBox(height: 40),
                 SizedBox(
                   width: double.infinity,
                   child: TextButton.icon(
                     onPressed: () {
                       Navigator.pop(context); // Close dialog first
                       auth.logout();
                     },
                     icon: const Icon(Icons.logout, color: Colors.redAccent),
                     label: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                     style: TextButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       backgroundColor: Colors.redAccent.withOpacity(0.1),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                     ),
                   ),
                 ),
                 const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, bool readOnly) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: readOnly ? Colors.white.withOpacity(0.03) : const Color(0xFF2A2D3E),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: TextStyle(color: readOnly ? Colors.white54 : Colors.white),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser!;
    
    // Stats Calculations
    final goalProgress = user.totalMinutesStudied / user.weeklyGoalMinutes;
    final displayTimeH = user.totalMinutesStudied ~/ 60;
    final displayTimeM = user.totalMinutesStudied % 60;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: "Logout",
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]
          )
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 40, 20, 100), // Padding for Nav Bar
          children: [
            Center(child: Column(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC490FF), width: 2)),
                child: const CircleAvatar(radius: 50, backgroundColor: Colors.transparent, child: Icon(Icons.person, size: 50, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              Text("${user.firstName} ${user.lastName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("${user.role.toUpperCase()} • SEMESTER ${user.semester}", style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
            ])),
            const SizedBox(height: 20),
            
            // --- Edit Profile Button ---
            Center(
              child: ElevatedButton.icon(
                  onPressed: () => _showEditDialog(context, auth),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("EDIT PROFILE"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  )
              ),
            ),
            const SizedBox(height: 30),

            // --- Realtime Study Stats ---
             Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D3E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text("Weekly Goal", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 10),
                        Stack(alignment: Alignment.center, children: [
                          CircularProgressIndicator(value: goalProgress, strokeWidth: 8, backgroundColor: Colors.white10, color: const Color(0xFFC490FF)),
                          Text("${(goalProgress * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                        ])
                      ]
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D3E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text("Total Study Time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text("${user.totalMinutesStudied}m", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                        Text("${displayTimeH}h ${displayTimeM}m", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ]
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Achievements", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
        Wrap(spacing: 10, children: [
          if (user.points > 100) const Chip(label: Text("Quiz Master"), avatar: Icon(Icons.workspace_premium, size: 16, color: Colors.amber)),
          if (user.streak >= 1) const Chip(label: Text("Active Learner"), avatar: Icon(Icons.bolt, size: 16, color: Colors.orange)),
        ]),
        const SizedBox(height: 30),
            const SizedBox(height: 30),
            const Divider(color: Colors.white12),
            Container(
               decoration: BoxDecoration(
                 color: const Color(0xFF2A2D3E),
                 borderRadius: BorderRadius.circular(15),
                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
               ),
               child: ListTile(
                 leading: Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), shape: BoxShape.circle),
                   child: const Icon(Icons.cloud_done, color: Colors.greenAccent),
                 ),
                 title: const Text("System Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                 subtitle: const Text("Online • Synchronized", style: TextStyle(fontSize: 12, color: Colors.white54)),
               ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: auth.logout, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8), foregroundColor: Colors.white), child: const Text("LOGOUT")),
          ],
        ),
      ),
    );
  }
}
