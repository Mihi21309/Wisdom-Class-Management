import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/change_password_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/student/student_dashboard_screen.dart';
import '../../screens/teacher/teacher_dashboard_screen.dart';
import '../../tools/seed_firebase.dart';

/// Centralized route registry
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String changePassword = '/change-password';
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String home = '/home';
  static const String firebaseSetup = '/firebase-setup';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        changePassword: (context) => const ChangePasswordScreen(),
        adminDashboard: (context) => const AdminDashboardScreen(),
        teacherDashboard: (context) => const TeacherDashboardScreen(),
        home: (context) => const StudentDashboardScreen(),
        studentDashboard: (context) => const StudentDashboardScreen(),
        firebaseSetup: (context) => const FirebaseSetupScreen(),
      };
}
