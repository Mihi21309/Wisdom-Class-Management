class Student {
  final String uid; // Firebase Auth UID
  final String? studentId;
  final String name;
  final String email;
  final String phone;
  final List<String> enrolledBatches; // Batch IDs
  final String? profilePictureUrl;
  final DateTime enrollmentDate;
  final bool mustChangePassword;

  Student({
    required this.uid,
    this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.enrolledBatches,
    this.profilePictureUrl,
    required this.enrollmentDate,
    this.mustChangePassword = false,
  });

  // Convert Student to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'enrolledBatches': enrolledBatches,
      'profilePictureUrl': profilePictureUrl,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'mustChangePassword': mustChangePassword,
    };
  }

  // Create Student from Firestore document
  factory Student.fromJson(Map<String, dynamic> json, String uid) {
    return Student(
      uid: uid,
      studentId: json['studentId'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      enrolledBatches: List<String>.from(json['enrolledBatches'] ?? []),
      profilePictureUrl: json['profilePictureUrl'],
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'])
          : DateTime.now(),
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }

  // Create a copy with modifications
  Student copyWith({
    String? uid,
    String? studentId,
    String? name,
    String? email,
    String? phone,
    List<String>? enrolledBatches,
    String? profilePictureUrl,
    DateTime? enrollmentDate,
    bool? mustChangePassword,
  }) {
    return Student(
      uid: uid ?? this.uid,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      enrolledBatches: enrolledBatches ?? this.enrolledBatches,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
