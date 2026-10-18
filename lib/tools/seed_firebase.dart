import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// One-click Firebase Database Initializer / Seeder
/// Run this to automatically set up Admin, Teacher, Student, Batches, and Subjects in Firebase!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MaterialApp(
    home: FirebaseSetupScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FirebaseSetupScreen extends StatefulWidget {
  const FirebaseSetupScreen({super.key});

  @override
  State<FirebaseSetupScreen> createState() => _FirebaseSetupScreenState();
}

class _FirebaseSetupScreenState extends State<FirebaseSetupScreen> {
  final List<String> _logs = [];
  bool _isProcessing = false;
  bool _isCompleted = false;

  void _addLog(String msg) {
    setState(() {
      _logs.add(msg);
    });
  }

  Future<void> _startDatabaseSetup() async {
    setState(() {
      _isProcessing = true;
      _logs.clear();
      _isCompleted = false;
    });

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      _addLog('🚀 Starting automated database seeding...');

      // 1. Setup Batches
      _addLog('📁 Creating Batches...');
      final batch2026Ref = firestore.collection('batches').doc('batch_2026_al');
      await batch2026Ref.set({
        'name': '2026 A/L Science & Maths',
        'code': '2026-AL-SCI',
        'description': 'Advanced Level 2026 Batch',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final batch2027Ref = firestore.collection('batches').doc('batch_2027_al');
      await batch2027Ref.set({
        'name': '2027 A/L Foundation',
        'code': '2027-AL-FND',
        'description': 'Advanced Level 2027 Foundation Batch',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _addLog('✅ Batches created.');

      // 2. Setup Subjects
      _addLog('📚 Creating Subjects...');
      final mathRef = firestore.collection('subjects').doc('sub_maths');
      await mathRef.set({
        'name': 'Combined Mathematics',
        'code': 'MATH101',
        'teacher': 'Mr. Perera',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final physicsRef = firestore.collection('subjects').doc('sub_physics');
      await physicsRef.set({
        'name': 'Physics',
        'code': 'PHY101',
        'teacher': 'Dr. Silva',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _addLog('✅ Subjects created.');

      // 3. System Counters
      _addLog('⚙️ Initializing System ID Counters...');
      await firestore.collection('system').doc('studentCounter').set({'count': 1}, SetOptions(merge: true));
      await firestore.collection('system').doc('teacherCounter').set({'count': 1}, SetOptions(merge: true));
      _addLog('✅ Counters initialized.');

      // 4. Create Admin Account
      _addLog('👑 Setting up Admin account (admin@wisdom.com)...');
      String adminUid = '';
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: 'admin@wisdom.com',
          password: 'adminPassword123!',
        );
        adminUid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await auth.signInWithEmailAndPassword(
            email: 'admin@wisdom.com',
            password: 'adminPassword123!',
          );
          adminUid = cred.user!.uid;
        } else {
          rethrow;
        }
      }
      await firestore.collection('admins').doc(adminUid).set({
        'name': 'Wisdom Administrator',
        'email': 'admin@wisdom.com',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _addLog('✅ Admin account configured.');

      // 5. Create Teacher Account
      _addLog('👨‍🏫 Setting up Teacher account (teacher@wisdom.com)...');
      String teacherUid = '';
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: 'teacher@wisdom.com',
          password: 'teacherPassword123!',
        );
        teacherUid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await auth.signInWithEmailAndPassword(
            email: 'teacher@wisdom.com',
            password: 'teacherPassword123!',
          );
          teacherUid = cred.user!.uid;
        } else {
          rethrow;
        }
      }
      await firestore.collection('teachers').doc(teacherUid).set({
        'teacherId': 'TCH-0001',
        'name': 'Mr. K. Perera',
        'email': 'teacher@wisdom.com',
        'phone': '+94 77 123 4567',
        'assignedSubjectIds': ['sub_maths'],
        'assignedBatchIds': ['batch_2026_al'],
        'role': 'teacher',
        'createdAt': DateTime.now().toIso8601String(),
      });
      _addLog('✅ Teacher account configured.');

      // 6. Create Student Account
      _addLog('🎓 Setting up Student account (student@wisdom.com)...');
      String studentUid = '';
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: 'student@wisdom.com',
          password: 'studentPassword123!',
        );
        studentUid = cred.user!.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await auth.signInWithEmailAndPassword(
            email: 'student@wisdom.com',
            password: 'studentPassword123!',
          );
          studentUid = cred.user!.uid;
        } else {
          rethrow;
        }
      }
      await firestore.collection('students').doc(studentUid).set({
        'studentId': 'STU-000001',
        'name': 'Kasun Mendis',
        'email': 'student@wisdom.com',
        'phone': '+94 71 987 6543',
        'enrolledBatches': ['batch_2026_al'],
        'enrollmentDate': DateTime.now().toIso8601String(),
        'mustChangePassword': false,
        'role': 'student',
      });
      _addLog('✅ Student account configured.');

      // 7. Create Sample Zoom Live Class
      _addLog('📹 Creating Sample Live Zoom Class...');
      await firestore.collection('classes').add({
        'classTitle': 'Combined Maths 2026 Theory & Revision',
        'batchId': 'batch_2026_al',
        'subjectId': 'sub_maths',
        'zoomLink': 'https://zoom.us/j/1234567890',
        'scheduledDateTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'durationMinutes': 120,
        'description': 'Algebra & Differential Calculus Session',
        'createdAt': DateTime.now().toIso8601String(),
      });
      _addLog('✅ Sample Class created.');

      // Sign out current seed session
      await auth.signOut();

      _addLog('🎉 COMPLETE! All roles and collections are now ready in Firebase.');
      setState(() {
        _isCompleted = true;
      });
    } catch (e) {
      _addLog('❌ Error during setup: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Wisdom Firebase Auto-Setup'),
        backgroundColor: const Color(0xFF1E40AF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Automatic Firebase Setup',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'This script will populate your empty Firestore database with collections, counters, and 3 pre-configured login accounts for testing (Admin, Teacher, Student).',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _startDatabaseSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow),
              label: Text(_isProcessing ? 'Setting up Firebase...' : 'Run Auto Setup Now'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      _logs[i],
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: _logs[i].startsWith('❌')
                            ? Colors.redAccent
                            : _logs[i].startsWith('✅') || _logs[i].startsWith('🎉')
                                ? Colors.greenAccent
                                : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Ready to Login Credentials:',
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Admin: admin@wisdom.com / adminPassword123!\n'
                      'Teacher: teacher@wisdom.com / teacherPassword123!\n'
                      'Student: student@wisdom.com / studentPassword123!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
