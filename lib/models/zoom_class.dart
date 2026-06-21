class ZoomClass {
  final String id;
  final String classTitle;
  final String batchId;
  final String subjectId;
  final String zoomLink;
  final DateTime scheduledDateTime;
  final int durationMinutes;
  final String? description;
  final DateTime createdAt;

  ZoomClass({
    required this.id,
    required this.classTitle,
    required this.batchId,
    required this.subjectId,
    required this.zoomLink,
    required this.scheduledDateTime,
    required this.durationMinutes,
    this.description,
    required this.createdAt,
  });

  // Check if class is currently live (started but not ended)
  bool get isLive {
    final now = DateTime.now();
    final endTime = scheduledDateTime.add(Duration(minutes: durationMinutes));
    return now.isAfter(scheduledDateTime) && now.isBefore(endTime);
  }

  // Check if class is upcoming (hasn't started yet)
  bool get isUpcoming {
    return DateTime.now().isBefore(scheduledDateTime);
  }

  // Check if class has ended
  bool get hasEnded {
    final endTime = scheduledDateTime.add(Duration(minutes: durationMinutes));
    return DateTime.now().isAfter(endTime);
  }

  // Convert ZoomClass to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'classTitle': classTitle,
      'batchId': batchId,
      'subjectId': subjectId,
      'zoomLink': zoomLink,
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create ZoomClass from Firestore document
  factory ZoomClass.fromJson(Map<String, dynamic> json, String docId) {
    return ZoomClass(
      id: docId,
      classTitle: json['classTitle'] ?? '',
      batchId: json['batchId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      zoomLink: json['zoomLink'] ?? '',
      scheduledDateTime: json['scheduledDateTime'] != null
          ? DateTime.parse(json['scheduledDateTime'])
          : DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 60,
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Create a copy with modifications
  ZoomClass copyWith({
    String? id,
    String? classTitle,
    String? batchId,
    String? subjectId,
    String? zoomLink,
    DateTime? scheduledDateTime,
    int? durationMinutes,
    String? description,
    DateTime? createdAt,
  }) {
    return ZoomClass(
      id: id ?? this.id,
      classTitle: classTitle ?? this.classTitle,
      batchId: batchId ?? this.batchId,
      subjectId: subjectId ?? this.subjectId,
      zoomLink: zoomLink ?? this.zoomLink,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
