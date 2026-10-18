class Teacher {
  final String uid; // Firebase Auth UID
  final String? teacherId; // e.g. TCH-0001
  final String name;
  final String email;
  final String phone;
  final List<String> assignedSubjectIds;
  final List<String> assignedBatchIds;
  final String? profilePictureUrl;
  final DateTime createdAt;

  Teacher({
    required this.uid,
    this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.assignedSubjectIds,
    required this.assignedBatchIds,
    this.profilePictureUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'assignedSubjectIds': assignedSubjectIds,
      'assignedBatchIds': assignedBatchIds,
      'profilePictureUrl': profilePictureUrl,
      'role': 'teacher',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json, String uid) {
    return Teacher(
      uid: uid,
      teacherId: json['teacherId'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      assignedSubjectIds: List<String>.from(json['assignedSubjectIds'] ?? []),
      assignedBatchIds: List<String>.from(json['assignedBatchIds'] ?? []),
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Teacher copyWith({
    String? uid,
    String? teacherId,
    String? name,
    String? email,
    String? phone,
    List<String>? assignedSubjectIds,
    List<String>? assignedBatchIds,
    String? profilePictureUrl,
    DateTime? createdAt,
  }) {
    return Teacher(
      uid: uid ?? this.uid,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      assignedSubjectIds: assignedSubjectIds ?? this.assignedSubjectIds,
      assignedBatchIds: assignedBatchIds ?? this.assignedBatchIds,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
