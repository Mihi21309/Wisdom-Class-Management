class Batch {
  final String id;
  final String name;
  final String description;
  final int year;
  final List<String> subjectsOffered; // Subject IDs
  final List<String> enrolledStudents; // Student Auth UIDs
  final DateTime createdAt;

  Batch({
    required this.id,
    required this.name,
    required this.description,
    required this.year,
    required this.subjectsOffered,
    required this.enrolledStudents,
    required this.createdAt,
  });

  // Convert Batch to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'year': year,
      'subjectsOffered': subjectsOffered,
      'enrolledStudents': enrolledStudents,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Batch from Firestore document
  factory Batch.fromJson(Map<String, dynamic> json, String docId) {
    return Batch(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      subjectsOffered: List<String>.from(json['subjectsOffered'] ?? []),
      enrolledStudents: List<String>.from(json['enrolledStudents'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Create a copy with modifications
  Batch copyWith({
    String? id,
    String? name,
    String? description,
    int? year,
    List<String>? subjectsOffered,
    List<String>? enrolledStudents,
    DateTime? createdAt,
  }) {
    return Batch(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      year: year ?? this.year,
      subjectsOffered: subjectsOffered ?? this.subjectsOffered,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
