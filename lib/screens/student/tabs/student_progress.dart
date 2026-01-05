import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class StudentProgressTab extends StatelessWidget {
  const StudentProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser!;
    final theme = Theme.of(context);

    // Premium Colors
    final gradientStart = Color(0xFFC490FF);
    final gradientEnd = theme.primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text("Learning Overview", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10)
            ),
            child: const Row(
              children: [
                Text("Weekly", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), 
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 18)
              ]
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E), // Dark Navy
              const Color(0xFF16213E), // Slightly lighter
            ],
          )
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 100), // Increased bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bar Chart Section ---
              Container(
                height: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2A2D3E), const Color(0xFF212436)],
                    begin: Alignment.topLeft, 
                    end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.05))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Total Study Time", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "${user.totalMinutesStudied ~/ 60}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const TextSpan(text: "h ", style: TextStyle(fontSize: 16, color: Colors.white70)),
                                TextSpan(text: "${user.totalMinutesStudied % 60}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                const TextSpan(text: "m", style: TextStyle(fontSize: 16, color: Colors.white70)),
                              ]
                            )
                          ),
                        ]),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: gradientStart.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.bar_chart_rounded, color: gradientStart, size: 24),
                        )
                      ],
                    ),
                    const Spacer(),
                    // Stylish Bar Visualization (Mock data for days, but consistent style)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _premiumBar("Mon", 45, false),
                        _premiumBar("Tue", 65, false),
                        _premiumBar("Wed", 35, false),
                        _premiumBar("Thu", 75, false),
                        _premiumBar("Fri", 100, true, gradientStart, gradientEnd), // Highlight
                        _premiumBar("Sat", 55, false),
                        _premiumBar("Sun", 25, false),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- Summary Cards ---
              const Text("Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _summaryCard("Weekly Goal", "${user.weeklyGoalMinutes ~/ 60}h", Icons.timer_outlined, [const Color(0xFFC490FF), const Color(0xFF8E54E9)])),
                  const SizedBox(width: 20),
                  Expanded(child: _summaryCard("Vocab Mastery", "80%", Icons.rocket_launch_outlined, [const Color(0xFF4AC3FF), const Color(0xFF0084FF)])),
                ],
              ),
              
              const SizedBox(height: 30),
            
              // --- Streak Banner ---
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  boxShadow: [
                     BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Learning Streak", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text("${user.streak} Days!", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumBar(String day, double heightPct, bool isSelected, [Color? start, Color? end]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tooltip or value indicator could go here
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 14,
              height: 140, // Max height
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              width: 14,
              height: 140 * (heightPct / 100),
              decoration: BoxDecoration(
                gradient: isSelected && start != null && end != null
                    ? LinearGradient(colors: [start, end], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                    : LinearGradient(colors: [Colors.white24, Colors.white10], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected ? [
                  BoxShadow(color: start!.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                ] : null
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), 
        borderRadius: BorderRadius.circular(28),
         boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
         ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }
}
