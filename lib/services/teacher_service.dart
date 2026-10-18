import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher.dart';
import '../models/zoom_class.dart';
import '../models/batch.dart';
import '../models/student.dart';

class TeacherService {
  static final TeacherService _instance = TeacherService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory TeacherService() {
    return _instance;
  }

  TeacherService._internal();

  /// Check if the currently logged in user is a registered teacher
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

  /// Get teacher profile by Firebase Auth UID
  Future<Teacher?> getTeacherProfile(String uid) async {
    try {
      final doc = await _firestore.collection('teachers').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Teacher.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get teacher by custom ID (e.g. TCH-0001)
  Future<Teacher?> getTeacherByTeacherId(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('teachers')
          .where('teacherId', isEqualTo: teacherId.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Teacher.fromJson(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stream classes assigned to this teacher
  Stream<List<ZoomClass>> getTeacherClasses(String teacherUid) {
    return _firestore
        .collection('classes')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ZoomClass.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get all batches assigned to teacher
  Future<List<Batch>> getTeacherBatches(List<String> batchIds) async {
    if (batchIds.isEmpty) return [];
    try {
      final snapshot = await _firestore.collection('batches').get();
      return snapshot.docs
          .where((doc) => batchIds.contains(doc.id))
          .map((doc) => Batch.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get students enrolled in a specific batch
  Future<List<Student>> getStudentsInBatch(String batchId) async {
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

  /// Create / publish a new live class
  Future<void> createLiveClass({
    required String title,
    required String zoomLink,
    required int durationMinutes,
    required String batchId,
    required String subjectId,
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
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    await _firestore.collection('classes').add({
      'classTitle': title,
      'batchId': batchId,
      'batchName': '2026 A/L Science & Tech',
      'subjectId': subjectId,
      'subjectName': 'Combined Mathematics',
      'teacherId': currentTeacher?.uid ?? '',
      'teacherName': teacherName,
      'zoomLink': zoomLink,
      'date': dateStr,
      'time': timeStr,
      'scheduledDateTime': now.toIso8601String(),
      'durationMinutes': durationMinutes,
      'createdAt': now.toIso8601String(),
    });
  }

  /// Mark attendance for a student
  Future<void> markAttendance({
    required String classId,
    required String studentUid,
    required String batchId,
    required String subjectId,
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
      'subjectId': subjectId,
      'status': status,
      'date': dateStr,
      'markedBy': currentTeacher?.uid ?? 'teacher',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
