import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/teacher_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const TeacherScheduleTab(),
      const TeacherCreateClassTab(),
      const TeacherMarkAttendanceTab(),
      const TeacherMaterialsAndAssignmentsTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: const Color(0xFF059669).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF059669)),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF059669)),
            label: 'New Class',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_outlined),
            selectedIcon: Icon(Icons.how_to_reg, color: Color(0xFF059669)),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Color(0xFF059669)),
            label: 'Tasks & Notes',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 1: SCHEDULE & ZOOM LAUNCH (LIVE FIRESTORE)
// ─────────────────────────────────────────────────────────────
class TeacherScheduleTab extends StatelessWidget {
  const TeacherScheduleTab({super.key});

  Future<void> _launchZoom(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Zoom link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Educator Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF059669),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Teacher Profile Banner from Firestore
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('teachers').doc(currentUid).snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final name = data?['name'] ?? 'Teacher';
                final teacherId = data?['teacherId'] ?? 'TCH-0001';

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF047857), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.school, size: 34, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome, Educator', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Teacher ID: $teacherId • Online Active', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Live Classes Stream from Firestore
            const Text('Live & Scheduled Sessions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('classes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text('No live classes scheduled yet.', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = docs[i].data() as Map<String, dynamic>;
                    final title = c['classTitle'] ?? 'Live Class';
                    final zoomLink = c['zoomLink'] ?? '';
                    final duration = c['durationMinutes'] ?? 60;
                    final subject = c['subjectName'] ?? 'General Subject';
                    final batch = c['batchName'] ?? 'Enrolled Students';
                    final dateStr = c['date'] ?? 'Upcoming';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'LIVE READY',
                                  style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Subject: $subject • Batch: $batch • $duration mins ($dateStr)',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.videocam, size: 18),
                              label: const Text('Start / Host Live Zoom Session'),
                              onPressed: () => _launchZoom(context, zoomLink),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 2: CREATE LIVE CLASS (DYNAMIC FIRESTORE SELECTION)
// ─────────────────────────────────────────────────────────────
class TeacherCreateClassTab extends StatefulWidget {
  const TeacherCreateClassTab({super.key});

  @override
  State<TeacherCreateClassTab> createState() => _TeacherCreateClassTabState();
}

class _TeacherCreateClassTabState extends State<TeacherCreateClassTab> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController(text: 'https://zoom.us/j/');
  final _recordingController = TextEditingController();
  int _selectedDuration = 90;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  String? _selectedBatchId;
  String _selectedBatchName = '';
  String? _selectedSubjectId;
  String _selectedSubjectName = '';

  Future<void> _publishClass() async {
    final title = _titleController.text.trim();
    final link = _linkController.text.trim();

    if (title.isEmpty || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter class title and Zoom link')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      final scheduledDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

      final teacherService = TeacherService();
      await teacherService.createLiveClass(
        title: title,
        zoomLink: link,
        recordingLink: _recordingController.text.trim(),
        durationMinutes: _selectedDuration,
        batchId: _selectedBatchId ?? 'general_batch',
        batchName: _selectedBatchName.isNotEmpty ? _selectedBatchName : 'All Enrolled Batches',
        subjectId: _selectedSubjectId ?? 'general_sub',
        subjectName: _selectedSubjectName.isNotEmpty ? _selectedSubjectName : 'Core Subject',
        dateStr: dateStr,
        timeStr: timeStr,
        scheduledDateTime: scheduledDateTime,
      );

      _titleController.clear();
      _recordingController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class published successfully with scheduled date & time!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish class: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Schedule New Live Class'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Class Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Combined Maths Integration Session',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Real Firestore Batches Selection
            const Text('Select Academic Batch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('batches').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final validBatchId = docs.any((d) => d.id == _selectedBatchId) ? _selectedBatchId : null;
                return DropdownButtonFormField<String>(
                  initialValue: validBatchId,
                  decoration: InputDecoration(
                    hintText: docs.isEmpty ? 'No batches available' : 'Select target batch...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? doc.id;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final match = docs.firstWhere((d) => d.id == val);
                      final data = match.data() as Map<String, dynamic>;
                      setState(() {
                        _selectedBatchId = val;
                        _selectedBatchName = data['name'] ?? val;
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Real Firestore Subjects Selection
            const Text('Select Subject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final validSubjectId = docs.any((d) => d.id == _selectedSubjectId) ? _selectedSubjectId : null;
                return DropdownButtonFormField<String>(
                  initialValue: validSubjectId,
                  decoration: InputDecoration(
                    hintText: docs.isEmpty ? 'No subjects available' : 'Select subject...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? doc.id;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final match = docs.firstWhere((d) => d.id == val);
                      final data = match.data() as Map<String, dynamic>;
                      setState(() {
                        _selectedSubjectId = val;
                        _selectedSubjectName = data['name'] ?? val;
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            const Text('Zoom Meeting Link', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.link, color: Color(0xFF059669)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Class Date & Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF059669)),
                    label: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 7)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.access_time, size: 16, color: Color(0xFF059669)),
                    label: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text('Class Recording / Replay Link (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _recordingController,
              decoration: InputDecoration(
                hintText: 'e.g. https://youtube.com/... or Google Drive',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.play_circle_outline, color: Color(0xFF059669)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Class Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [60, 90, 120].map((dur) {
                final isSel = _selectedDuration == dur;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$dur mins'),
                    selected: isSel,
                    selectedColor: const Color(0xFF059669),
                    labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black),
                    onSelected: (val) {
                      setState(() => _selectedDuration = dur);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isSaving ? 'Publishing Class...' : 'Publish Class'),
                onPressed: _isSaving ? null : _publishClass,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 3: MARK ATTENDANCE (FIRESTORE STUDENTS & SESSIONS)
// ─────────────────────────────────────────────────────────────
class TeacherMarkAttendanceTab extends StatefulWidget {
  const TeacherMarkAttendanceTab({super.key});

  @override
  State<TeacherMarkAttendanceTab> createState() => _TeacherMarkAttendanceTabState();
}

class _TeacherMarkAttendanceTabState extends State<TeacherMarkAttendanceTab> {
  final Map<String, bool> _attendanceState = {};
  String? _selectedClassDocId;
  String? _selectedSessionTitle;
  String? _selectedBatchName;
  String? _selectedSubjectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mark Class Attendance'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allStudentDocs = snapshot.data?.docs ?? [];
          if (allStudentDocs.isEmpty) {
            return const Center(
              child: Text('No students registered in this batch yet.', style: TextStyle(color: Colors.grey)),
            );
          }

          // Filter students by selected batch if a session is chosen
          final filteredStudents = allStudentDocs.where((doc) {
            if (_selectedBatchName == null || _selectedBatchName!.isEmpty || _selectedBatchName == 'All Batches') {
              return true;
            }
            final data = doc.data() as Map<String, dynamic>;
            final enrolled = List<String>.from(data['enrolledBatches'] ?? []);
            return enrolled.contains(_selectedBatchName);
          }).toList();

          int presentCount = filteredStudents.where((d) => _attendanceState[d.id] ?? true).length;
          int absentCount = filteredStudents.length - presentCount;

          return Column(
            children: [
              // Session Selector Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Class Session Stream from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('classes').snapshots(),
                      builder: (context, classSnap) {
                        final classDocs = classSnap.data?.docs ?? [];
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedClassDocId,
                          decoration: InputDecoration(
                            labelText: 'Select Class Session for Attendance *',
                            hintText: classDocs.isEmpty ? 'No scheduled classes available' : 'Choose class session...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: classDocs.map((cd) {
                            final cdata = cd.data() as Map<String, dynamic>;
                            final title = cdata['classTitle'] ?? 'Session ${cd.id}';
                            final batch = cdata['batchName'] ?? '';
                            return DropdownMenuItem<String>(
                              value: cd.id,
                              child: Text(
                                batch.isNotEmpty ? '$title ($batch)' : title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final match = classDocs.firstWhere((cd) => cd.id == val);
                              final cdata = match.data() as Map<String, dynamic>;
                              setState(() {
                                _selectedClassDocId = val;
                                _selectedSessionTitle = cdata['classTitle'] ?? 'Class Session';
                                _selectedBatchName = cdata['batchName'] ?? 'All Batches';
                                _selectedSubjectName = cdata['subjectName'] ?? 'General Subject';
                              });
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Live Student Roster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              _selectedBatchName != null && _selectedBatchName != 'All Batches'
                                  ? 'Batch: $_selectedBatchName (${filteredStudents.length} enrolled)'
                                  : 'Showing all students (${filteredStudents.length})',
                              style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                              child: Text('Present: $presentCount',
                                  style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                              child: Text('Absent: $absentCount',
                                  style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredStudents.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              Text(
                                'No students enrolled in "$_selectedBatchName" yet.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredStudents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final data = filteredStudents[i].data() as Map<String, dynamic>;
                          final docId = filteredStudents[i].id;
                          final name = data['name'] ?? 'Student';
                          final studentId = data['studentId'] ?? 'STU-000000';
                          final isPresent = _attendanceState[docId] ?? true;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFF059669).withValues(alpha: 0.15),
                                      child: Text(name.isNotEmpty ? name[0] : 'S',
                                          style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(studentId, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isPresent,
                                  activeThumbColor: const Color(0xFF059669),
                                  onChanged: (val) {
                                    setState(() {
                                      _attendanceState[docId] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save & Submit Attendance'),
                    onPressed: filteredStudents.isEmpty
                        ? null
                        : () async {
                            final teacherService = TeacherService();
                            final sessionTitle = _selectedSessionTitle ?? 'Live Lecture Session';
                            final classId = _selectedClassDocId ?? sessionTitle;
                            final batchName = _selectedBatchName ?? 'All Batches';
                            final subjectName = _selectedSubjectName ?? 'General Subject';

                            for (final doc in filteredStudents) {
                              final isPresent = _attendanceState[doc.id] ?? true;
                              await teacherService.markAttendance(
                                classId: classId,
                                studentUid: doc.id,
                                batchId: batchName,
                                batchName: batchName,
                                subjectId: subjectName,
                                subjectName: subjectName,
                                status: isPresent ? 'present' : 'absent',
                              );
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Attendance records saved for this class session!'),
                                  backgroundColor: Color(0xFF059669),
                                ),
                              );
                            }
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 4: TASKS & MATERIALS (FIRESTORE ASSIGNMENTS)
// ─────────────────────────────────────────────────────────────
class TeacherMaterialsAndAssignmentsTab extends StatelessWidget {
  const TeacherMaterialsAndAssignmentsTab({super.key});

  void _showCreateAssignmentDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: 'Combined Mathematics');
    final teacherCtrl = TextEditingController(text: 'Teacher');
    final dueCtrl = TextEditingController(text: 'Next Monday');
    final pointsCtrl = TextEditingController(text: '100');
    final resourceLinkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Homework / Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Assignment Title *', hintText: 'e.g. Calculus Problem Set 1')),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Subject *'),
                    hint: Text(docs.isEmpty ? 'No subjects available' : 'Choose subject...'),
                    items: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = data['name'] ?? d.id;
                      return DropdownMenuItem<String>(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) subjectCtrl.text = val;
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              TextField(controller: teacherCtrl, decoration: const InputDecoration(labelText: 'Teacher / Instructor')),
              const SizedBox(height: 8),
              TextField(controller: dueCtrl, decoration: const InputDecoration(labelText: 'Due Date *', hintText: 'e.g. Friday, 5 PM')),
              const SizedBox(height: 8),
              TextField(controller: pointsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Points')),
              const SizedBox(height: 8),
              TextField(
                controller: resourceLinkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Worksheet / Material Link (Optional)',
                  hintText: 'https://drive.google.com/... or PDF link',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('assignments').add({
                'title': titleCtrl.text.trim(),
                'subject': subjectCtrl.text.trim(),
                'teacher': teacherCtrl.text.trim(),
                'dueDate': dueCtrl.text.trim(),
                'resourceLink': resourceLinkCtrl.text.trim(),
                'submittedStudentUids': <String>[],
                'totalPoints': int.tryParse(pointsCtrl.text.trim()) ?? 100,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Homework task published successfully!')),
                );
              }
            },
            child: const Text('Publish Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Course Materials & Homework'),
        backgroundColor: const Color(0xFF059669),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Create Assignment',
            onPressed: () => _showCreateAssignmentDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
        onPressed: () => _showCreateAssignmentDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Material Card
            _buildActionCard(
              title: 'Upload Study Material / PDF Notes',
              subtitle: 'Share theory handouts & lecture slides with enrolled batches',
              icon: Icons.upload_file,
              color: const Color(0xFF2563EB),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Storage file picker triggered for course materials.')),
                );
              },
            ),
            const SizedBox(height: 20),

            // Live Firestore Assignments List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Published Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF059669)),
                  onPressed: () => _showCreateAssignmentDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text('No homework assignments published yet. Tap "New Assignment" to add one.',
                          style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final task = d.data() as Map<String, dynamic>;
                    final title = task['title'] ?? 'Task';
                    final subject = task['subject'] ?? 'General';
                    final due = task['dueDate'] ?? 'Soon';
                    final pts = task['totalPoints'] ?? 100;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFFEF3C7),
                            child: const Icon(Icons.assignment, color: Color(0xFFD97706), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('$subject • Due: $due • $pts Pts',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('assignments').doc(d.id).delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Assignment deleted successfully.')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 14, color: color),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
