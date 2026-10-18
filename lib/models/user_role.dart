enum UserRole {
  admin,
  teacher,
  student,
  unknown;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Educator / Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.unknown:
        return 'Guest';
    }
  }
}
