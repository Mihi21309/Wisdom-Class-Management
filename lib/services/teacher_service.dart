import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory TeacherService() {
    return _instance;
  }

  TeacherService._internal();

  /// Check if the current user is a teacher
  Future<bool> isCurrentUserTeacher() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('teachers').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Resolve teacher profile by teacher ID
  Future<Map<String, dynamic>?> getTeacherByTeacherId(String teacherId) async {
    try {
      final query = await _firestore
          .collection('teachers')
          .where('teacherId', isEqualTo: teacherId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return query.docs.first.data();
    } catch (e) {
      return null;
    }
  }

  /// Get classes assigned to current teacher
  Stream<QuerySnapshot> streamTeacherClasses() {
    final currentTeacher = _auth.currentUser;
    if (currentTeacher == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: currentTeacher.uid)
        .snapshots();
  }

  /// Get students enrolled in a specific batch
  Future<List<Student>> getStudentsForBatch(String batchId) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('enrolledBatches', arrayContains: batchId)
          .get();

      return snapshot.docs
          .map((doc) => Student.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Create / publish a new live class with dynamic batch and subject
  Future<void> createLiveClass({
    required String title,
    required String zoomLink,
    required int durationMinutes,
    required String batchId,
    required String batchName,
    required String subjectId,
    required String subjectName,
    String? dateStr,
    String? timeStr,
    DateTime? scheduledDateTime,
    String? recordingLink,
  }) async {
    final currentTeacher = _auth.currentUser;
    String teacherName = 'Faculty Educator';
    if (currentTeacher != null) {
      try {
        final tDoc = await _firestore.collection('teachers').doc(currentTeacher.uid).get();
        if (tDoc.exists && tDoc.data() != null) {
          teacherName = tDoc.data()!['name'] ?? currentTeacher.displayName ?? 'Faculty Educator';
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final effectiveDate = dateStr ?? '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final effectiveTime = timeStr ?? '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final effectiveScheduled = (scheduledDateTime ?? now).toIso8601String();

    await _firestore.collection('classes').add({
      'classTitle': title,
      'batchId': batchId,
      'batchName': batchName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': currentTeacher?.uid ?? '',
      'teacherName': teacherName,
      'zoomLink': zoomLink,
      'recordingLink': recordingLink ?? '',
      'date': effectiveDate,
      'time': effectiveTime,
      'scheduledDateTime': effectiveScheduled,
      'durationMinutes': durationMinutes,
      'createdAt': now.toIso8601String(),
    });
  }

  /// Mark attendance for a student with dynamic session information
  Future<void> markAttendance({
    required String classId,
    required String studentUid,
    required String batchId,
    required String batchName,
    required String subjectId,
    required String subjectName,
    required String status, // 'present', 'absent', 'late'
  }) async {
    final currentTeacher = _auth.currentUser;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _firestore.collection('attendance').add({
      'classId': classId,
      'studentId': studentUid,
      'studentUid': studentUid,
      'batchId': batchId,
      'batchName': batchName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'status': status,
      'date': dateStr,
      'markedBy': currentTeacher?.uid ?? 'teacher',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
