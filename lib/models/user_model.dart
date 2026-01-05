class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String role;
  final String semester;
  final int points;
  final int streak;
  final int totalMinutesStudied;
  final int weeklyGoalMinutes;
  
  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.semester,
    this.points = 0,
    this.streak = 0,
    this.totalMinutesStudied = 0,
    this.weeklyGoalMinutes = 600, // Default 10 hours
  });
}
