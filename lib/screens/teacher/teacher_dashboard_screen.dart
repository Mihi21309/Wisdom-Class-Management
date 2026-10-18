import 'package:flutter/material.dart';
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
// TEACHER TAB 1: SCHEDULE & ZOOM LAUNCH
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Educator Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF059669),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF047857), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.school, size: 34, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, Educator', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Mr. K. Perera', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Combined Mathematics • Batch 2026', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live / Scheduled Sessions
            const Text("Today's Live Classes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
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
                      const Text('Combined Maths: Differential Calculus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('LIVE NOW', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('10:00 AM - 12:00 PM • 28 Students Enrolled', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.video_call, size: 18),
                      label: const Text('Start / Host Zoom Class'),
                      onPressed: () => _launchZoom(context, 'https://zoom.us/j/1234567890'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 2: CREATE NEW CLASS (PROPOSAL SCREEN 13)
// ─────────────────────────────────────────────────────────────
class TeacherCreateClassTab extends StatefulWidget {
  const TeacherCreateClassTab({super.key});

  @override
  State<TeacherCreateClassTab> createState() => _TeacherCreateClassTabState();
}

class _TeacherCreateClassTabState extends State<TeacherCreateClassTab> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController(text: 'https://zoom.us/j/');
  int _selectedDuration = 90;

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
                hintText: 'e.g. Physics Wave Mechanics Revision',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
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
                icon: const Icon(Icons.check),
                label: const Text('Publish & Notify Students'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live class successfully scheduled and notified!')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 3: MARK ATTENDANCE (PROPOSAL SCREEN 16)
// ─────────────────────────────────────────────────────────────
class TeacherMarkAttendanceTab extends StatefulWidget {
  const TeacherMarkAttendanceTab({super.key});

  @override
  State<TeacherMarkAttendanceTab> createState() => _TeacherMarkAttendanceTabState();
}

class _TeacherMarkAttendanceTabState extends State<TeacherMarkAttendanceTab> {
  final List<Map<String, dynamic>> _students = [
    {'name': 'Kasun Mendis', 'id': 'STU-000001', 'present': true},
    {'name': 'Asel Sewwandi', 'id': 'STU-000002', 'present': true},
    {'name': 'Dinuka Kumara', 'id': 'STU-000003', 'present': false},
    {'name': 'Nadeesha Dilhani', 'id': 'STU-000004', 'present': true},
    {'name': 'Sanjaya Rathnayake', 'id': 'STU-000005', 'present': true},
  ];

  @override
  Widget build(BuildContext context) {
    int presentCount = _students.where((s) => s['present'] == true).length;
    int absentCount = _students.length - presentCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mark Class Attendance'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Combined Maths Theory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Batch 2026 • Today Session', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                      child: Text('Present: $presentCount', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                      child: Text('Absent: $absentCount', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = _students[i];
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
                            child: Text(s['name'][0], style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(s['id'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: s['present'] as bool,
                        activeColor: const Color(0xFF059669),
                        onChanged: (val) {
                          setState(() {
                            s['present'] = val;
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attendance records saved to Firestore!')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TEACHER TAB 4: TASKS & MATERIALS (PROPOSAL SCREEN 14 & 15)
// ─────────────────────────────────────────────────────────────
class TeacherMaterialsAndAssignmentsTab extends StatelessWidget {
  const TeacherMaterialsAndAssignmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Course Materials & Homework'),
        backgroundColor: const Color(0xFF059669),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionCard(
              title: 'Upload Study Material / PDF Notes',
              subtitle: 'Share theory handouts & lecture slides with enrolled batches',
              icon: Icons.upload_file,
              color: const Color(0xFF2563EB),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker opened for study materials')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Create & Assign Homework',
              subtitle: 'Publish assignments, set deadlines, and collect student submissions',
              icon: Icons.post_add,
              color: const Color(0xFFD97706),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignment publisher opened')),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              onPressed: onTap,
              child: const Text('Open Tool', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
