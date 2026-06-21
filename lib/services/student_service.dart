import 'package:wisdom_class_management/models/student.dart';
import 'package:wisdom_class_management/models/batch.dart';
import 'package:wisdom_class_management/models/subject.dart';
import 'package:wisdom_class_management/models/attendance.dart';
import 'package:wisdom_class_management/models/zoom_class.dart';
import 'firebase_service.dart';

/// Service for managing student data in Firestore
class StudentService {
  static final StudentService _instance = StudentService._internal();
  final FirebaseService _firebaseService = FirebaseService();

  factory StudentService() {
    return _instance;
  }

  StudentService._internal();

  // ===== STUDENT OPERATIONS =====

  /// Fetch student profile by UID
  Future<Student?> getStudentProfile(String uid) async {
    try {
      final doc = await _firebaseService.getDocument('students', uid).get();
      if (doc.exists) {
        return Student.fromJson(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Failed to fetch student profile: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Create a new student profile
  Future<void> createStudentProfile({
    required String uid,
    String? studentId,
    required String name,
    required String email,
    required String phone,
    bool mustChangePassword = true,
  }) async {
    try {
      final student = Student(
        uid: uid,
        studentId: studentId,
        name: name,
        email: email,
        phone: phone,
        enrolledBatches: [],
        enrollmentDate: DateTime.now(),
        mustChangePassword: mustChangePassword,
      );
      await _firebaseService.getDocument('students', uid).set(student.toJson());
    } catch (e) {
      throw Exception(
        'Failed to create student profile: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Fetch student profile by student ID
  Future<Student?> getStudentByStudentId(String studentId) async {
    try {
      final snapshot = await _firebaseService
          .getCollection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return Student.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception(
        'Failed to fetch student by ID: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Check if a student must change password
  Future<bool> mustChangePassword(String uid) async {
    try {
      final doc = await _firebaseService.getDocument('students', uid).get();
      if (!doc.exists) {
        return false;
      }
      final data = doc.data() as Map<String, dynamic>;
      return data['mustChangePassword'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Update the password-change flag for a student
  Future<void> setMustChangePassword(String uid, bool value) async {
    try {
      await _firebaseService.getDocument('students', uid).update({
        'mustChangePassword': value,
      });
    } catch (e) {
      throw Exception(
        'Failed to update password status: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Update student profile
  Future<void> updateStudentProfile(String uid, Student student) async {
    try {
      await _firebaseService
          .getDocument('students', uid)
          .update(student.toJson());
    } catch (e) {
      throw Exception(
        'Failed to update student profile: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Stream student profile (real-time updates)
  Stream<Student?> streamStudentProfile(String uid) {
    return _firebaseService.getDocument('students', uid).snapshots().map((doc) {
      if (doc.exists) {
        return Student.fromJson(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    });
  }

  // ===== BATCH OPERATIONS =====

  /// Get all batches
  Future<List<Batch>> getAllBatches() async {
    try {
      final snapshot = await _firebaseService.getCollection('batches').get();
      return snapshot.docs
          .map(
            (doc) => Batch.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch batches: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Get batches for a specific student
  Future<List<Batch>> getEnrolledBatches(String studentUid) async {
    try {
      // First get student profile to get enrolled batch IDs
      final student = await getStudentProfile(studentUid);
      if (student == null) {
        return [];
      }

      // Fetch all enrolled batches
      final batches = <Batch>[];
      for (final batchId in student.enrolledBatches) {
        final doc = await _firebaseService
            .getDocument('batches', batchId)
            .get();
        if (doc.exists) {
          batches.add(
            Batch.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          );
        }
      }
      return batches;
    } catch (e) {
      throw Exception(
        'Failed to fetch enrolled batches: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Stream enrolled batches (real-time updates)
  Stream<List<Batch>> streamEnrolledBatches(String studentUid) {
    return streamStudentProfile(studentUid).asyncExpand((student) async* {
      if (student == null) {
        yield [];
        return;
      }

      try {
        final batches = <Batch>[];
        for (final batchId in student.enrolledBatches) {
          final doc = await _firebaseService
              .getDocument('batches', batchId)
              .get();
          if (doc.exists) {
            batches.add(
              Batch.fromJson(doc.data() as Map<String, dynamic>, doc.id),
            );
          }
        }
        yield batches;
      } catch (e) {
        yield [];
      }
    });
  }

  /// Get specific batch by ID
  Future<Batch?> getBatchById(String batchId) async {
    try {
      final doc = await _firebaseService.getDocument('batches', batchId).get();
      if (doc.exists) {
        return Batch.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Failed to fetch batch: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  // ===== SUBJECT OPERATIONS =====

  /// Get subject by ID
  Future<Subject?> getSubjectById(String subjectId) async {
    try {
      final doc = await _firebaseService
          .getDocument('subjects', subjectId)
          .get();
      if (doc.exists) {
        return Subject.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Failed to fetch subject: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Get subjects by IDs
  Future<List<Subject>> getSubjectsByIds(List<String> subjectIds) async {
    try {
      final subjects = <Subject>[];
      for (final subjectId in subjectIds) {
        final subject = await getSubjectById(subjectId);
        if (subject != null) {
          subjects.add(subject);
        }
      }
      return subjects;
    } catch (e) {
      throw Exception(
        'Failed to fetch subjects: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  // ===== ATTENDANCE OPERATIONS =====

  /// Get attendance records for student in a specific month/year
  Future<List<Attendance>> getAttendanceByMonth(
    String studentId,
    int month,
    int year,
  ) async {
    try {
      final snapshot = await _firebaseService
          .getCollection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Attendance.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch attendance: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Get attendance records for student in a batch for specific month/year
  Future<List<Attendance>> getAttendanceByBatchAndMonth(
    String studentId,
    String batchId,
    int month,
    int year,
  ) async {
    try {
      final snapshot = await _firebaseService
          .getCollection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('batchId', isEqualTo: batchId)
          .where('month', isEqualTo: month)
          .where('year', isEqualTo: year)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                Attendance.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch attendance: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Stream attendance records for real-time updates
  Stream<List<Attendance>> streamAttendanceByMonth(
    String studentId,
    int month,
    int year,
  ) {
    return _firebaseService
        .getCollection('attendance')
        .where('studentId', isEqualTo: studentId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Attendance.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get attendance statistics for a student in a batch
  Future<Map<String, double>> getAttendanceStats(
    String studentId,
    String batchId,
  ) async {
    try {
      final snapshot = await _firebaseService
          .getCollection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('batchId', isEqualTo: batchId)
          .get();

      final docs = snapshot.docs;
      if (docs.isEmpty) {
        return {'present': 0, 'absent': 0, 'leave': 0, 'percentage': 0};
      }

      int presentCount = 0;
      int absentCount = 0;
      int leaveCount = 0;

      for (final doc in docs) {
        final attendance = Attendance.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        if (attendance.status.name == 'present') {
          presentCount++;
        } else if (attendance.status.name == 'absent') {
          absentCount++;
        } else if (attendance.status.name == 'leave') {
          leaveCount++;
        }
      }

      final total = presentCount + absentCount + leaveCount;
      final percentage = total > 0
          ? ((presentCount / total) * 100).toDouble()
          : 0.0;

      return {
        'present': presentCount.toDouble(),
        'absent': absentCount.toDouble(),
        'leave': leaveCount.toDouble(),
        'percentage': percentage,
      };
    } catch (e) {
      throw Exception(
        'Failed to calculate attendance stats: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  // ===== ZOOM CLASS OPERATIONS =====

  /// Get Zoom classes for a specific batch
  Future<List<ZoomClass>> getZoomClassesForBatch(String batchId) async {
    try {
      final snapshot = await _firebaseService
          .getCollection('zoomClasses')
          .where('batchId', isEqualTo: batchId)
          .orderBy('scheduledDateTime', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                ZoomClass.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to fetch Zoom classes: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Get upcoming Zoom classes for a student
  Future<List<ZoomClass>> getUpcomingZoomClasses(String studentUid) async {
    try {
      // Get student's enrolled batches
      final batches = await getEnrolledBatches(studentUid);
      final batchIds = batches.map((b) => b.id).toList();

      if (batchIds.isEmpty) {
        return [];
      }

      final now = DateTime.now();
      final allClasses = <ZoomClass>[];

      for (final batchId in batchIds) {
        final snapshot = await _firebaseService
            .getCollection('zoomClasses')
            .where('batchId', isEqualTo: batchId)
            .where(
              'scheduledDateTime',
              isGreaterThanOrEqualTo: now.toIso8601String(),
            )
            .orderBy('scheduledDateTime')
            .get();

        allClasses.addAll(
          snapshot.docs
              .map(
                (doc) => ZoomClass.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
      }

      // Sort by scheduled date time
      allClasses.sort(
        (a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime),
      );
      return allClasses;
    } catch (e) {
      throw Exception(
        'Failed to fetch upcoming classes: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }

  /// Stream Zoom classes for a batch (real-time updates)
  Stream<List<ZoomClass>> streamZoomClassesForBatch(String batchId) {
    return _firebaseService
        .getCollection('zoomClasses')
        .where('batchId', isEqualTo: batchId)
        .orderBy('scheduledDateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ZoomClass.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get Zoom class by ID
  Future<ZoomClass?> getZoomClassById(String classId) async {
    try {
      final doc = await _firebaseService
          .getDocument('zoomClasses', classId)
          .get();
      if (doc.exists) {
        return ZoomClass.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception(
        'Failed to fetch Zoom class: ${FirebaseService.handleFirestoreException(e)}',
      );
    }
  }
}
