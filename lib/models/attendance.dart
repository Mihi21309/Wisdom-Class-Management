enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  leave('Leave');

  final String label;
  const AttendanceStatus(this.label);
}

class Attendance {
  final String id;
  final String studentId; // Firebase Auth UID
  final String batchId;
  final String subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final int month; // For easy filtering (1-12)
  final int year; // For easy filtering

  Attendance({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.subjectId,
    required this.date,
    required this.status,
    required this.month,
    required this.year,
  });

  // Convert Attendance to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'batchId': batchId,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'status': status.name,
      'month': month,
      'year': year,
    };
  }

  // Create Attendance from Firestore document
  factory Attendance.fromJson(Map<String, dynamic> json, String docId) {
    return Attendance(
      id: docId,
      studentId: json['studentId'] ?? '',
      batchId: json['batchId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }

  // Create a copy with modifications
  Attendance copyWith({
    String? id,
    String? studentId,
    String? batchId,
    String? subjectId,
    DateTime? date,
    AttendanceStatus? status,
    int? month,
    int? year,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      status: status ?? this.status,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
