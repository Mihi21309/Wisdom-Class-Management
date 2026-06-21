import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/student/student_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the default Flutter splash
  await Future.delayed(Duration.zero);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E40AF)),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/home': (context) => const HomeScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
      },
    );
  }
}
