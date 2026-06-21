class Subject {
  final String id;
  final String name;
  final String code;
  final String teacher;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.teacher,
  });

  // Convert Subject to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'teacher': teacher};
  }

  // Create Subject from Firestore document
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      teacher: json['teacher'] ?? '',
    );
  }

  // Create a copy with modifications
  Subject copyWith({String? id, String? name, String? code, String? teacher}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacher: teacher ?? this.teacher,
    );
  }
}
