import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'manage_students_screen.dart';
import 'create_student_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const AdminHomeTab(),
      const ManageStudentsScreen(),
      const ManageTeachersTab(),
      const AdminReportsTab(),
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
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: AppColors.primary),
            label: 'Teachers',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment, color: AppColors.primary),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1: ADMIN HOME / OVERVIEW
// ─────────────────────────────────────────────────────────────
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
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
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wisdom Educational Unit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Central Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Academic Year 2026 / 2027', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Grid
            const Text('System Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard('Total Students', '248', Icons.groups, const Color(0xFF2563EB)),
                _buildStatCard('Faculty Teachers', '18', Icons.school, const Color(0xFF059669)),
                _buildStatCard('Active Batches', '6', Icons.class_, const Color(0xFFD97706)),
                _buildStatCard('Live Attendance', '92.4%', Icons.verified_user, const Color(0xFF7C3AED)),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Quick Administrative Tools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Student', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateStudentScreen(
                            batchId: 'batch_2026_al',
                            batchName: '2026 A/L Science & Maths',
                            subjects: [
                              {'id': 'sub_maths', 'name': 'Combined Mathematics', 'code': 'MATH101'},
                              {'id': 'sub_physics', 'name': 'Physics', 'code': 'PHY101'},
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: const Text('DB Seed Tool', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/firebase-setup');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 3: MANAGE TEACHERS (PROPOSAL SCREEN 19)
// ─────────────────────────────────────────────────────────────
class ManageTeachersTab extends StatelessWidget {
  const ManageTeachersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final teachers = [
      {'id': 'TCH-0001', 'name': 'Mr. K. Perera', 'subject': 'Combined Mathematics', 'batch': '2026 A/L'},
      {'id': 'TCH-0002', 'name': 'Dr. N. Silva', 'subject': 'Physics', 'batch': '2026 / 2027 A/L'},
      {'id': 'TCH-0003', 'name': 'Mrs. I. Fernando', 'subject': 'Chemistry', 'batch': '2026 A/L'},
      {'id': 'TCH-0004', 'name': 'Mr. S. Wickramasinghe', 'subject': 'Information Tech (ICT)', 'batch': '2027 A/L'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Faculty & Teachers'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: teachers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final t = teachers[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF059669).withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${t['subject']} • ${t['batch']}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Text('Teacher ID: ${t['id']}', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 4: REPORTS & ANALYTICS (PROPOSAL SCREEN 20)
// ─────────────────────────────────────────────────────────────
class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Academic Reports & Analytics'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportCard(
              context: context,
              title: 'Monthly Attendance Analytics',
              subtitle: 'Batch 2026 Combined Maths (92% Average)',
              icon: Icons.pie_chart,
              color: const Color(0xFF2563EB),
              barItems: [
                {'label': 'Combined Maths', 'percent': 0.92, 'text': '92%'},
                {'label': 'Physics', 'percent': 0.88, 'text': '88%'},
                {'label': 'Chemistry', 'percent': 0.85, 'text': '85%'},
              ],
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context: context,
              title: 'Student Enrollment Breakdown',
              subtitle: 'Active: 231 • On Leave: 17',
              icon: Icons.analytics,
              color: const Color(0xFF059669),
              barItems: [
                {'label': '2026 A/L Science', 'percent': 0.95, 'text': '145'},
                {'label': '2027 A/L Foundation', 'percent': 0.70, 'text': '103'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> barItems,
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...barItems.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(b['text'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: b['percent'],
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export PDF Report', style: TextStyle(fontSize: 12)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report PDF downloaded successfully!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
