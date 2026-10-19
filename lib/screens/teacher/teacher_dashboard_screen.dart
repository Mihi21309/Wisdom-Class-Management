import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

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
      const TeacherStudentsAndBatchesTab(),
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: Color(0xFF059669)),
            label: 'Students & Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: Color(0xFF059669)),
            label: 'Materials & Tasks',
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
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting link configured for this session.')),
      );
      return;
    }
    final uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: url.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zoom link copied to clipboard.')),
        );
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of the Educator Workspace?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Teacher Profile & Schedule Stream from Firestore
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('teachers').doc(currentUid).snapshots(),
              builder: (context, teacherSnap) {
                final tdata = teacherSnap.data?.data() as Map<String, dynamic>?;
                final teacherName = (tdata?['name'] ?? 'Teacher').toString().trim();
                final teacherId = tdata?['teacherId'] ?? 'TCH-0001';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
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
                                Text(teacherName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                Text('Teacher ID: $teacherId • Online Active', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                            width: double.infinity,
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
                            final assignedTeacher = (c['teacherName'] ?? '').toString().trim();
                            final dateStr = c['date'] ?? 'Upcoming';

                            final isAssignedToMe = assignedTeacher.isNotEmpty &&
                                teacherName.isNotEmpty &&
                                (assignedTeacher.toLowerCase() == teacherName.toLowerCase() ||
                                    assignedTeacher.toLowerCase().contains(teacherName.toLowerCase()));

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAssignedToMe ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                  width: isAssignedToMe ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  if (isAssignedToMe)
                                    BoxShadow(
                                      color: const Color(0xFF059669).withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
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
                                          color: isAssignedToMe ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAssignedToMe
                                              ? 'ASSIGNED TO YOU'
                                              : (assignedTeacher.isNotEmpty ? 'TEACHER: $assignedTeacher' : 'OPEN CLASS'),
                                          style: TextStyle(
                                            color: isAssignedToMe ? const Color(0xFF059669) : const Color(0xFF475569),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Subject: $subject • Batch: $batch • Assigned: ${assignedTeacher.isNotEmpty ? assignedTeacher : 'Unassigned'}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Duration: $duration mins • Date: $dateStr',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.login, size: 18),
                                      label: Text(
                                        isAssignedToMe ? 'Join Live Class Session' : 'Join Class as Educator',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
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
// TEACHER TAB 2: MY STUDENTS & BATCHES (REAL FIRESTORE)
// ─────────────────────────────────────────────────────────────
class TeacherStudentsAndBatchesTab extends StatefulWidget {
  const TeacherStudentsAndBatchesTab({super.key});

  @override
  State<TeacherStudentsAndBatchesTab> createState() => _TeacherStudentsAndBatchesTabState();
}

class _TeacherStudentsAndBatchesTabState extends State<TeacherStudentsAndBatchesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedBatch = 'All Batches';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on record for this student.')),
      );
      return;
    }
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: clean));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone $clean copied to clipboard.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Students & Batches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF059669),
      ),
      body: Column(
        children: [
          // Filter Bar Container
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by student name, ID or phone...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF059669)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),

                // Batch Selection Dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('batches').snapshots(),
                  builder: (context, snapshot) {
                    final batchDocs = snapshot.data?.docs ?? [];
                    final batchNames = <String>['All Batches'];
                    for (final doc in batchDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? doc.id).toString().trim();
                      if (name.isNotEmpty && !batchNames.contains(name)) {
                        batchNames.add(name);
                      }
                    }

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: batchNames.contains(_selectedBatch) ? _selectedBatch : 'All Batches',
                      decoration: InputDecoration(
                        labelText: 'Filter by Academic Batch',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                        prefixIcon: const Icon(Icons.class_outlined, size: 18, color: Color(0xFF059669)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      items: batchNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBatch = val);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Students Roster
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data?.docs ?? [];
                final filtered = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final studentId = (data['studentId'] ?? '').toString().toLowerCase();
                  final phone = (data['phone'] ?? '').toString().toLowerCase();

                  // Search query filter
                  if (_searchQuery.isNotEmpty) {
                    final matches = name.contains(_searchQuery) ||
                        studentId.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                    if (!matches) return false;
                  }

                  // Batch filter
                  if (_selectedBatch != 'All Batches') {
                    final enrolledBatches = <String>[];
                    if (data['enrolledBatches'] is List) {
                      for (final b in (data['enrolledBatches'] as List)) {
                        if (b != null) enrolledBatches.add(b.toString().toLowerCase().trim());
                      }
                    }
                    final singleBatch = (data['batch'] ?? data['batchName'])?.toString().toLowerCase().trim();
                    if (singleBatch != null && singleBatch.isNotEmpty) {
                      enrolledBatches.add(singleBatch);
                    }

                    if (!enrolledBatches.contains(_selectedBatch.toLowerCase().trim())) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 54, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'No Students Found',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedBatch != 'All Batches'
                                ? 'No students are currently enrolled in "$_selectedBatch".'
                                : 'No registered students match your search criteria.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Student';
                    final studentId = data['studentId'] ?? 'STU-ONLINE';
                    final email = data['email'] ?? '';
                    final phone = data['phone'] ?? '';
                    final feeStatus = data['feeStatus'] ?? 'Paid';
                    final isPaid = feeStatus == 'Paid';

                    // Enrolled batches
                    final batches = <String>[];
                    if (data['enrolledBatches'] is List) {
                      for (final b in (data['enrolledBatches'] as List)) {
                        if (b != null && b.toString().trim().isNotEmpty) {
                          batches.add(b.toString().trim());
                        }
                      }
                    }
                    final singleBatch = (data['batch'] ?? data['batchName'])?.toString().trim();
                    if (singleBatch != null && singleBatch.isNotEmpty && !batches.contains(singleBatch)) {
                      batches.add(singleBatch);
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFD1FAE5),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                  style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text('ID: $studentId • $email',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isPaid ? 'Active Tuition' : 'Fee Due',
                                  style: TextStyle(
                                    color: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (batches.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: batches.map((b) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone.isNotEmpty ? phone : 'No phone',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                  ),
                                ],
                              ),
                              if (phone.isNotEmpty)
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: const Color(0xFF059669),
                                  ),
                                  icon: const Icon(Icons.phone, size: 14),
                                  label: const Text('Call Student', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () => _callPhone(context, phone),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 3: MATERIALS & HOMEWORK (REAL FIRESTORE)
// ─────────────────────────────────────────────────────────────
class TeacherMaterialsAndAssignmentsTab extends StatefulWidget {
  const TeacherMaterialsAndAssignmentsTab({super.key});

  @override
  State<TeacherMaterialsAndAssignmentsTab> createState() => _TeacherMaterialsAndAssignmentsTabState();
}

class _TeacherMaterialsAndAssignmentsTabState extends State<TeacherMaterialsAndAssignmentsTab> {
  int _selectedFilterIndex = 0; // 0: All, 1: Homework, 2: Study Notes

  Future<void> _openResource(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No external document link provided for this item.')),
      );
      return;
    }
    final uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: url.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard (could not open directly).')),
        );
      }
    }
  }

  void _showCreateMaterialDialog(BuildContext context, String teacherName, String teacherUid) {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    final dueCtrl = TextEditingController(text: 'Next Monday, 5:00 PM');
    final pointsCtrl = TextEditingController(text: '100');
    String selectedType = 'homework'; // 'homework' or 'notes'
    String selectedBatch = 'All Batches';
    String selectedSubject = 'General';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isHomework = selectedType == 'homework';
          return AlertDialog(
            title: Text(isHomework ? 'Publish Homework Task' : 'Share Study Notes / PDF'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Selection Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Homework Task')),
                          selected: isHomework,
                          selectedColor: const Color(0xFF059669),
                          labelStyle: TextStyle(
                            color: isHomework ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = 'homework');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Study Notes / PDF')),
                          selected: !isHomework,
                          selectedColor: const Color(0xFF7C3AED),
                          labelStyle: TextStyle(
                            color: !isHomework ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = 'notes');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: isHomework ? 'Assignment Title *' : 'Material Title *',
                      hintText: isHomework ? 'e.g. Calculus Problem Set 1' : 'e.g. Wave Optics Theory Handout',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Batch Dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('batches').snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      final batchNames = <String>['All Batches'];
                      for (final d in docs) {
                        final data = d.data() as Map<String, dynamic>;
                        final bname = (data['name'] ?? d.id).toString().trim();
                        if (bname.isNotEmpty && !batchNames.contains(bname)) {
                          batchNames.add(bname);
                        }
                      }
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: batchNames.contains(selectedBatch) ? selectedBatch : 'All Batches',
                        decoration: const InputDecoration(labelText: 'Target Batch *'),
                        items: batchNames.map((name) {
                          return DropdownMenuItem<String>(value: name, child: Text(name, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedBatch = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Subject Dropdown
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      final subNames = <String>['General Subject'];
                      for (final d in docs) {
                        final data = d.data() as Map<String, dynamic>;
                        final sname = (data['name'] ?? d.id).toString().trim();
                        if (sname.isNotEmpty && !subNames.contains(sname)) {
                          subNames.add(sname);
                        }
                      }
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: subNames.contains(selectedSubject) ? selectedSubject : subNames.first,
                        decoration: const InputDecoration(labelText: 'Select Subject *'),
                        items: subNames.map((name) {
                          return DropdownMenuItem<String>(value: name, child: Text(name, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedSubject = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: linkCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Document / Cloud Drive Link *',
                      hintText: 'https://drive.google.com/... or PDF URL',
                    ),
                  ),

                  if (isHomework) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: dueCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Due Date *',
                        hintText: 'e.g. Friday, 5:00 PM',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pointsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Points',
                        hintText: '100',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHomework ? const Color(0xFF059669) : const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title.')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  await FirebaseFirestore.instance.collection('assignments').add({
                    'title': titleCtrl.text.trim(),
                    'type': selectedType,
                    'batchName': selectedBatch,
                    'subject': selectedSubject,
                    'resourceLink': linkCtrl.text.trim(),
                    'teacher': teacherName.isNotEmpty ? teacherName : 'Instructor',
                    'teacherUid': teacherUid,
                    'dueDate': isHomework ? dueCtrl.text.trim() : 'Study Resource',
                    'totalPoints': isHomework ? (int.tryParse(pointsCtrl.text.trim()) ?? 100) : 0,
                    'submittedStudentUids': <String>[],
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isHomework ? 'Homework published successfully!' : 'Study material shared successfully!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  }
                },
                child: Text(isHomework ? 'Publish Homework' : 'Share Material'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Course Materials & Homework', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF059669),
      ),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').doc(currentUid).snapshots(),
        builder: (context, snapshot) {
          final tdata = snapshot.data?.data() as Map<String, dynamic>?;
          final teacherName = (tdata?['name'] ?? 'Teacher').toString().trim();

          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Post Material / Task', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _showCreateMaterialDialog(context, teacherName, currentUid),
          );
        },
      ),
      body: Column(
        children: [
          // Filter Chips Row (Horizontally Scrollable for all screen widths)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('All Items', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip('Homework Tasks', 1),
                  const SizedBox(width: 8),
                  _buildFilterChip('Study Notes', 2),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Materials List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('assignments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final type = (data['type'] ?? 'homework').toString().toLowerCase();
                  if (_selectedFilterIndex == 1) return type == 'homework';
                  if (_selectedFilterIndex == 2) return type == 'notes';
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'No Items Published Yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "Post Material / Task" to share study handouts or homework with your batches.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final subject = data['subject'] ?? 'General';
                    final batch = data['batchName'] ?? 'All Batches';
                    final teacher = data['teacher'] ?? 'Instructor';
                    final dueDate = data['dueDate'] ?? 'Open';
                    final resourceLink = (data['resourceLink'] ?? '').toString().trim();
                    final type = (data['type'] ?? 'homework').toString().toLowerCase();
                    final isHomework = type == 'homework';
                    final points = data['totalPoints'] ?? 100;
                    final submittedCount = (data['submittedStudentUids'] as List?)?.length ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isHomework ? const Color(0xFFEFF6FF) : const Color(0xFFF5F3FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isHomework ? 'HOMEWORK' : 'STUDY NOTES',
                                      style: TextStyle(
                                        color: isHomework ? const Color(0xFF1E40AF) : const Color(0xFF7C3AED),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      subject,
                                      style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                tooltip: 'Delete Item',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete Material'),
                                      content: Text('Are you sure you want to delete "$title"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                                          onPressed: () => Navigator.pop(c, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance.collection('assignments').doc(doc.id).delete();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Item deleted successfully.')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'Batch: $batch • By: $teacher',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          if (isHomework) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Due: $dueDate • $points Points • $submittedCount Submissions',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 12),

                          // Action Link Button
                          if (resourceLink.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isHomework ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                                  side: BorderSide(color: isHomework ? const Color(0xFF93C5FD) : const Color(0xFFC4B5FD)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: Text(
                                  isHomework ? 'Open Worksheet / Resource Link' : 'Open Study Handout / Notes',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                onPressed: () => _openResource(context, resourceLink),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF059669),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedFilterIndex = index);
      },
    );
  }
}
