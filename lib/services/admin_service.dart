import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StudentService _studentService = StudentService();

  factory AdminService() {
    return _instance;
  }

  AdminService._internal();

  /// Check if current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('admins').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get next student ID
  Future<String> getNextStudentId() async {
    try {
      final counterDoc = await _firestore
          .collection('system')
          .doc('studentCounter')
          .get();
      int nextNum = 1;

      if (counterDoc.exists) {
        nextNum = (counterDoc.data()?['count'] ?? 0) + 1;
      }

      await _firestore.collection('system').doc('studentCounter').set({
        'count': nextNum,
      });

      return 'STU-${nextNum.toString().padLeft(6, '0')}';
    } catch (e) {
      throw Exception('Failed to generate student ID: $e');
    }
  }

  /// Generate random temporary password
  String generateTempPassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = math.Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Create a new student account with auto-generated ID and temp password
  Future<Map<String, String>> createStudent({
    required String name,
    required String email,
    required String phone,
    required String batchId,
    required List<String> subjectIds,
  }) async {
    try {
      // Generate student ID and temp password
      final studentId = await getNextStudentId();
      final tempPassword = generateTempPassword();

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      final uid = userCredential.user!.uid;

      // Create student profile in Firestore
      await _studentService.createStudentProfile(
        uid: uid,
        studentId: studentId,
        name: name,
        email: email,
        phone: phone,
        mustChangePassword: true,
      );

      // Enroll student in batch and subjects
      await _firestore.collection('students').doc(uid).update({
        'enrolledBatches': [batchId],
        'enrolledSubjects': subjectIds,
      });

      // Add student to batch's enrolledStudents list
      await _firestore.collection('batches').doc(batchId).update({
        'enrolledStudents': FieldValue.arrayUnion([uid]),
      });

      return {'studentId': studentId, 'tempPassword': tempPassword, 'uid': uid};
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  /// Get all batches
  Future<List<Map<String, dynamic>>> getAllBatches() async {
    try {
      final snapshot = await _firestore.collection('batches').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'year': data['year'] ?? 0,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch batches: $e');
    }
  }

  /// Get subjects for a specific batch
  Future<List<Map<String, dynamic>>> getSubjectsForBatch(String batchId) async {
    try {
      final batchDoc = await _firestore
          .collection('batches')
          .doc(batchId)
          .get();
      if (!batchDoc.exists) return [];

      final subjectIds = List<String>.from(
        batchDoc.data()?['subjectsOffered'] ?? [],
      );
      if (subjectIds.isEmpty) return [];

      final subjects = <Map<String, dynamic>>[];
      for (final subjectId in subjectIds) {
        final subjectDoc = await _firestore
            .collection('subjects')
            .doc(subjectId)
            .get();
        if (subjectDoc.exists) {
          final data = subjectDoc.data();
          subjects.add({
            'id': subjectId,
            'name': data?['name'] ?? '',
            'code': data?['code'] ?? '',
            'teacher': data?['teacher'] ?? '',
          });
        }
      }
      return subjects;
    } catch (e) {
      throw Exception('Failed to fetch subjects: $e');
    }
  }

  /// Get students in a batch, optionally filtered by subject
  Future<List<Map<String, dynamic>>> getStudentsInBatch(
    String batchId, {
    String? subjectId,
  }) async {
    try {
      final batchDoc = await _firestore
          .collection('batches')
          .doc(batchId)
          .get();
      if (!batchDoc.exists) return [];

      final studentUids = List<String>.from(
        batchDoc.data()?['enrolledStudents'] ?? [],
      );

      final students = <Map<String, dynamic>>[];
      for (final uid in studentUids) {
        final studentDoc = await _firestore
            .collection('students')
            .doc(uid)
            .get();
        if (studentDoc.exists) {
          final data = studentDoc.data();

          // Filter by subject if provided
          if (subjectId != null) {
            final enrolledSubjects = List<String>.from(
              data?['enrolledSubjects'] ?? [],
            );
            if (!enrolledSubjects.contains(subjectId)) continue;
          }

          students.add({
            'uid': uid,
            'studentId': data?['studentId'] ?? '',
            'name': data?['name'] ?? '',
            'email': data?['email'] ?? '',
            'phone': data?['phone'] ?? '',
            'enrolledSubjects': List<String>.from(
              data?['enrolledSubjects'] ?? [],
            ),
          });
        }
      }
      return students;
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String uid, String batchId) async {
    try {
      // Remove from batch's enrolledStudents
      await _firestore.collection('batches').doc(batchId).update({
        'enrolledStudents': FieldValue.arrayRemove([uid]),
      });

      // Delete student document
      await _firestore.collection('students').doc(uid).delete();

      // Delete Firebase Auth user
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == uid) {
        await user?.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final batchesSnapshot = await _firestore.collection('batches').get();
      final studentsSnapshot = await _firestore.collection('students').get();

      return {
        'totalBatches': batchesSnapshot.docs.length,
        'totalStudents': studentsSnapshot.docs.length,
      };
    } catch (e) {
      return {'totalBatches': 0, 'totalStudents': 0};
    }
  }
}
