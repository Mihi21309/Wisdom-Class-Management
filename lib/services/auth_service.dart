import 'package:firebase_auth/firebase_auth.dart';
import '../../services/student_service.dart';
import '../../services/admin_service.dart';
import '../../services/teacher_service.dart';
import '../../models/user_role.dart';

class AuthResult {
  final bool success;
  final UserRole role;
  final bool mustChangePassword;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.role = UserRole.unknown,
    this.mustChangePassword = false,
    this.errorMessage,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StudentService _studentService = StudentService();
  final AdminService _adminService = AdminService();
  final TeacherService _teacherService = TeacherService();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Authenticate user and determine their system role (Admin, Teacher, Student)
  Future<AuthResult> login({
    required String loginInput,
    required String password,
  }) async {
    try {
      final input = loginInput.trim();
      String? emailToUse;

      if (input.contains('@')) {
        emailToUse = input;
      } else {
        // Resolve student ID
        final student = await _studentService.getStudentByStudentId(input);
        if (student != null) {
          emailToUse = student.email;
        } else {
          // Resolve teacher ID
          final teacher = await _teacherService.getTeacherByTeacherId(input);
          emailToUse = teacher?['email'] as String?;
        }
      }

      if (emailToUse == null || emailToUse.isEmpty) {
        return AuthResult(
          success: false,
          errorMessage: 'Account ID or Email not found.',
        );
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: emailToUse,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        return AuthResult(
          success: false,
          errorMessage: 'Authentication failed. Please try again.',
        );
      }

      // 1. Check Admin
      final isAdmin = await _adminService.isCurrentUserAdmin();
      if (isAdmin) {
        return AuthResult(success: true, role: UserRole.admin);
      }

      // 2. Check Teacher
      final isTeacher = await _teacherService.isCurrentUserTeacher();
      if (isTeacher) {
        return AuthResult(success: true, role: UserRole.teacher);
      }

      // 3. Student Check
      final mustChange = await _studentService.mustChangePassword(user.uid);
      return AuthResult(
        success: true,
        role: UserRole.student,
        mustChangePassword: mustChange,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email or ID.';
          break;
        case 'wrong-password':
          message = 'Invalid password entered.';
          break;
        case 'invalid-credential':
          message = 'Invalid email/ID or password.';
          break;
        case 'user-disabled':
          message = 'This account has been deactivated.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Authentication error occurred.';
      }
      return AuthResult(success: false, errorMessage: message);
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
