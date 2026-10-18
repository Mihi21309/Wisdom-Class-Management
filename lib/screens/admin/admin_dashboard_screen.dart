import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../services/admin_service.dart';

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
      AdminHomeTab(onNavigate: (index) => setState(() => _currentIndex = index)),
      const AdminManageStudentsTab(),
      const AdminManageTeachersTab(),
      const AdminManageClassesTab(),
      const AdminManageBatchesTab(),
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
            icon: Icon(Icons.video_camera_front_outlined),
            selectedIcon: Icon(Icons.video_camera_front, color: AppColors.primary),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_, color: AppColors.primary),
            label: 'Batches',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1: ADMIN OVERVIEW & QUICK METRICS
// ─────────────────────────────────────────────────────────────
class AdminHomeTab extends StatelessWidget {
  final void Function(int index)? onNavigate;

  const AdminHomeTab({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Wisdom Admin Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
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
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Wisdom Educational Unit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Administrator Portal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Institute Management Active', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Database Counters
            const Text('Institute Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    collection: 'students',
                    label: 'Students',
                    icon: Icons.people,
                    color: const Color(0xFF2563EB),
                    onTap: () => onNavigate?.call(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    collection: 'teachers',
                    label: 'Teachers',
                    icon: Icons.school,
                    color: const Color(0xFF059669),
                    onTap: () => onNavigate?.call(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    collection: 'classes',
                    label: 'Classes',
                    icon: Icons.video_camera_front,
                    color: const Color(0xFF7C3AED),
                    onTap: () => onNavigate?.call(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    collection: 'batches',
                    label: 'Batches',
                    icon: Icons.class_,
                    color: const Color(0xFFD97706),
                    onTap: () => onNavigate?.call(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Management Shortcuts
            const Text('Management Shortcuts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Manage Students',
              subtitle: 'Enroll, view records, and manage student accounts',
              icon: Icons.person_add_alt_1,
              color: const Color(0xFF2563EB),
              onTap: () => onNavigate?.call(1),
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Manage Teachers',
              subtitle: 'Register teachers, assign subjects, and manage staff',
              icon: Icons.school,
              color: const Color(0xFF059669),
              onTap: () => onNavigate?.call(2),
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Manage Classes & Schedules',
              subtitle: 'Schedule classes, set Zoom links, and update sessions',
              icon: Icons.videocam,
              color: const Color(0xFF7C3AED),
              onTap: () => onNavigate?.call(3),
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              title: 'Manage Academic Batches',
              subtitle: 'Create batches, assign academic streams, and curriculum',
              icon: Icons.class_,
              color: const Color(0xFFD97706),
              onTap: () => onNavigate?.call(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String collection,
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
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
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CREDENTIALS POPUP HELPER FOR ADMIN
// ─────────────────────────────────────────────────────────────
void _showCredentialsGeneratedDialog(BuildContext context, Map<String, String> creds) {
  final role = creds['role'] ?? 'User';
  final name = creds['name'] ?? '';
  final id = creds['id'] ?? '';
  final email = creds['email'] ?? '';
  final password = creds['password'] ?? '';
  final extra = creds['batch'] ?? creds['subject'] ?? '';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$role Credentials Ready!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Copy or save these credentials to share with the user for their first login.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildCredentialRow('Full Name', name),
                  const Divider(height: 16),
                  _buildCredentialRow('$role ID', id, isCopyable: true, context: ctx),
                  const Divider(height: 16),
                  _buildCredentialRow('Email Address', email, isCopyable: true, context: ctx),
                  const Divider(height: 16),
                  _buildCredentialRow('Temporary Password', password, isCopyable: true, isHighlight: true, context: ctx),
                  if (extra.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildCredentialRow(creds['batch'] != null ? 'Assigned Batch' : 'Primary Subject', extra),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy All Credentials'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final summary = StringBuffer();
                summary.writeln('🎓 Wisdom Class Management - Login Credentials');
                summary.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                summary.writeln('Role: $role');
                summary.writeln('Name: $name');
                summary.writeln('$role ID: $id');
                summary.writeln('Email: $email');
                summary.writeln('Temporary Password: $password');
                if (extra.isNotEmpty) {
                  summary.writeln(creds['batch'] != null ? 'Batch: $extra' : 'Subject: $extra');
                }
                summary.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                summary.writeln('👉 Log in to Wisdom Class Management using either your $role ID or Email, along with this password.');

                Clipboard.setData(ClipboardData(text: summary.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Credentials copied! Ready to paste into WhatsApp / SMS.'),
                    backgroundColor: Color(0xFF16A34A),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCredentialRow(String label, String value, {bool isCopyable = false, bool isHighlight = false, BuildContext? context}) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isHighlight ? const Color(0xFF1E40AF) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
      if (isCopyable && context != null)
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          tooltip: 'Copy $label',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied $label: $value'), duration: const Duration(seconds: 1)),
            );
          },
        ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// TAB 2: STUDENT MANAGEMENT (FULL CRUD)
// ─────────────────────────────────────────────────────────────
class AdminManageStudentsTab extends StatefulWidget {
  const AdminManageStudentsTab({super.key});

  @override
  State<AdminManageStudentsTab> createState() => _AdminManageStudentsTabState();
}

class _AdminManageStudentsTabState extends State<AdminManageStudentsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final studentIdCtrl = TextEditingController(
      text: 'STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    final passwordCtrl = TextEditingController(text: 'Wisdom@${DateTime.now().year}');
    String? selectedBatch;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Register New Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name *', hintText: 'e.g. Kasun Perera'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'kasun@wisdom.com'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Contact *', hintText: '0771234567'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: studentIdCtrl,
                  decoration: const InputDecoration(labelText: 'Student ID *', hintText: 'STU-000000'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Initial Password *',
                    hintText: 'e.g. Wisdom@2026',
                    helperText: 'Temporary login password for the student',
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('batches').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Text('No batches available yet.', style: TextStyle(color: Colors.grey, fontSize: 12));
                    }
                    final uniqueBatches = docs.map((b) {
                      final bdata = b.data() as Map<String, dynamic>;
                      return (bdata['name'] ?? b.id).toString();
                    }).toSet().toList();

                    final validValue = uniqueBatches.contains(selectedBatch) ? selectedBatch : null;

                    return DropdownButtonFormField<String>(
                      initialValue: validValue,
                      hint: const Text('Choose an academic batch...'),
                      decoration: const InputDecoration(labelText: 'Select Academic Batch *'),
                      items: uniqueBatches.map((bname) {
                        return DropdownMenuItem<String>(value: bname, child: Text(bname));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedBatch = val);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name and Email are required.')),
                        );
                        return;
                      }
                      if (passwordCtrl.text.trim().length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters.')),
                        );
                        return;
                      }

                      setModalState(() => isSubmitting = true);

                      try {
                        final creds = await AdminService().registerStudent(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          studentId: studentIdCtrl.text.trim(),
                          batchName: selectedBatch ?? 'General Batch',
                          password: passwordCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (context.mounted) {
                          _showCredentialsGeneratedDialog(context, creds);
                        }
                      } catch (e) {
                        setModalState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final emailCtrl = TextEditingController(text: data['email'] ?? '');
    final phoneCtrl = TextEditingController(text: data['phone'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Student Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('students').doc(doc.id).update({
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student details updated in Firestore!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Student';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to permanently delete $name from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('students').doc(doc.id).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student deleted successfully.')),
                );
              }
            },
            child: const Text('Delete Permanently'),
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
        title: const Text('Student Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Student',
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
        onPressed: () => _showAddStudentDialog(context),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
          ),

          // Live Student Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final m = d.data() as Map<String, dynamic>;
                  final name = (m['name'] ?? '').toString().toLowerCase();
                  final sid = (m['studentId'] ?? '').toString().toLowerCase();
                  final email = (m['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || sid.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No students found matching search.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unnamed';
                    final studentId = data['studentId'] ?? 'STU-000';
                    final email = data['email'] ?? '';
                    final phone = data['phone'] ?? '';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        studentId,
                                        style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final currentStatus = data['feeStatus'] ?? 'Paid';
                                        final newStatus = currentStatus == 'Paid' ? 'Due' : 'Paid';
                                        final month = data['feeMonth'] ?? 'October 2026';
                                        await AdminService().updateStudentFeeStatus(
                                          studentDocId: doc.id,
                                          feeStatus: newStatus,
                                          feeMonth: month,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('$name fee marked as $newStatus ($month)'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (data['feeStatus'] ?? 'Paid') == 'Paid'
                                              ? const Color(0xFFD1FAE5)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              (data['feeStatus'] ?? 'Paid') == 'Paid'
                                                  ? Icons.check_circle
                                                  : Icons.warning_amber_rounded,
                                              size: 11,
                                              color: (data['feeStatus'] ?? 'Paid') == 'Paid'
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFDC2626),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              (data['feeStatus'] ?? 'Paid') == 'Paid'
                                                  ? 'Fee: Paid'
                                                  : 'Fee: Due',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: (data['feeStatus'] ?? 'Paid') == 'Paid'
                                                    ? const Color(0xFF059669)
                                                    : const Color(0xFFDC2626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (phone.isNotEmpty)
                                      Text('📞 $phone', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF2563EB)),
                                tooltip: 'Edit',
                                onPressed: () => _showEditStudentDialog(context, doc),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDeleteStudent(context, doc),
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
// TAB 3: TEACHER MANAGEMENT (FULL CRUD)
// ─────────────────────────────────────────────────────────────
class AdminManageTeachersTab extends StatefulWidget {
  const AdminManageTeachersTab({super.key});

  @override
  State<AdminManageTeachersTab> createState() => _AdminManageTeachersTabState();
}

class _AdminManageTeachersTabState extends State<AdminManageTeachersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showAddTeacherDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: 'Combined Mathematics');
    final teacherIdCtrl = TextEditingController(
      text: 'TCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    final passwordCtrl = TextEditingController(text: 'Wisdom@${DateTime.now().year}');
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.school, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text('Register Teacher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Teacher Name *', hintText: 'e.g. Dr. K. Perera'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address *', hintText: 'perera@wisdom.com'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Contact *', hintText: '0779876543'),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Text('No subjects available yet.', style: TextStyle(color: Colors.grey, fontSize: 12));
                    }
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Primary Subject *'),
                      items: docs.map((d) {
                        final sdata = d.data() as Map<String, dynamic>;
                        final sname = sdata['name'] ?? d.id;
                        return DropdownMenuItem<String>(value: sname, child: Text(sname));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) subjectCtrl.text = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: teacherIdCtrl,
                  decoration: const InputDecoration(labelText: 'Teacher ID *', hintText: 'TCH-0001'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Initial Password *',
                    hintText: 'e.g. Wisdom@2026',
                    helperText: 'Temporary login password for the teacher',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name and Email are required.')),
                        );
                        return;
                      }
                      if (passwordCtrl.text.trim().length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters.')),
                        );
                        return;
                      }

                      setModalState(() => isSubmitting = true);

                      try {
                        final creds = await AdminService().registerTeacher(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          teacherId: teacherIdCtrl.text.trim(),
                          subject: subjectCtrl.text.trim().isEmpty ? 'General Subject' : subjectCtrl.text.trim(),
                          password: passwordCtrl.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (context.mounted) {
                          _showCredentialsGeneratedDialog(context, creds);
                        }
                      } catch (e) {
                        setModalState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create Teacher'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final emailCtrl = TextEditingController(text: data['email'] ?? '');
    final phoneCtrl = TextEditingController(text: data['phone'] ?? '');
    final subjectCtrl = TextEditingController(text: data['subject'] ?? 'General Subject');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Teacher Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Teacher Name')),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 8),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('teachers').doc(doc.id).update({
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'subject': subjectCtrl.text.trim(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher updated in Firestore!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeacher(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Teacher';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Teacher?'),
        content: Text('Are you sure you want to remove $name from the system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('teachers').doc(doc.id).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Teacher removed successfully.')),
                );
              }
            },
            child: const Text('Delete Permanently'),
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
        title: const Text('Teacher Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF059669),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Teacher',
            onPressed: () => _showAddTeacherDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Teacher'),
        onPressed: () => _showAddTeacherDialog(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search teachers by name, ID, or subject...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final m = d.data() as Map<String, dynamic>;
                  final name = (m['name'] ?? '').toString().toLowerCase();
                  final tid = (m['teacherId'] ?? '').toString().toLowerCase();
                  final subject = (m['subject'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || tid.contains(_searchQuery) || subject.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No teachers found matching search.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Teacher';
                    final teacherId = data['teacherId'] ?? 'TCH-000';
                    final email = data['email'] ?? '';
                    final subject = data['subject'] ?? 'Core Subjects';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFD1FAE5),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'T',
                              style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD1FAE5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        teacherId,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$subject • $email',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF059669)),
                                tooltip: 'Edit',
                                onPressed: () => _showEditTeacherDialog(context, doc),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDeleteTeacher(context, doc),
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
// TAB 4: CLASSES & ZOOM SESSIONS (FULL CRUD)
// ─────────────────────────────────────────────────────────────
class AdminManageClassesTab extends StatefulWidget {
  const AdminManageClassesTab({super.key});

  @override
  State<AdminManageClassesTab> createState() => _AdminManageClassesTabState();
}

class _AdminManageClassesTabState extends State<AdminManageClassesTab> {
  Future<void> _launchZoom(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddClassDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController(text: 'https://zoom.us/j/');
    final recordingCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: 'Combined Mathematics');
    final batchCtrl = TextEditingController(text: '2026 A/L Science & Tech');
    final teacherCtrl = TextEditingController(text: 'Mr. K. Perera');
    int selectedDuration = 90;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.video_call, color: Color(0xFF7C3AED)),
              SizedBox(width: 8),
              Text('Schedule Live Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Class Title *', hintText: 'e.g. Calculus & Vectors'),
                ),
                const SizedBox(height: 10),
                // Dynamic Subject from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final unique = docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['name'] ?? d.id).toString();
                    }).toSet().toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Subject *'),
                      hint: Text(unique.isEmpty ? 'No subjects available' : 'Choose subject...'),
                      items: unique.map((name) {
                        return DropdownMenuItem<String>(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) subjectCtrl.text = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Dynamic Batch from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('batches').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final unique = docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['name'] ?? d.id).toString();
                    }).toSet().toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Target Batch *'),
                      hint: Text(unique.isEmpty ? 'No batches available' : 'Choose batch...'),
                      items: unique.map((name) {
                        return DropdownMenuItem<String>(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) batchCtrl.text = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Dynamic Teacher from Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    final unique = docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['name'] ?? d.id).toString();
                    }).toSet().toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Assign Teacher *'),
                      hint: Text(unique.isEmpty ? 'No teachers registered' : 'Choose teacher...'),
                      items: unique.map((name) {
                        return DropdownMenuItem<String>(value: name, child: Text(name));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) teacherCtrl.text = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text('Session Schedule Date & Time *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 15, color: Color(0xFF7C3AED)),
                        label: Text(
                          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 7)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 15, color: Color(0xFF7C3AED)),
                        label: Text(
                          selectedTime.format(context),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: linkCtrl,
                  decoration: const InputDecoration(labelText: 'Live Zoom Meeting Link *', hintText: 'https://zoom.us/...'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: recordingCtrl,
                  decoration: const InputDecoration(labelText: 'Recording / Playback Link (Optional)', hintText: 'https://youtube.com/... or Google Drive'),
                ),
                const SizedBox(height: 12),
                const Text('Duration (Minutes)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Row(
                  children: [60, 90, 120, 180].map((dur) {
                    final isSel = selectedDuration == dur;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$dur m'),
                        selected: isSel,
                        selectedColor: const Color(0xFF7C3AED),
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black, fontSize: 11),
                        onSelected: (val) {
                          setModalState(() => selectedDuration = dur);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || linkCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and Zoom link are required.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final dateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                final scheduledDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);

                await FirebaseFirestore.instance.collection('classes').add({
                  'classTitle': titleCtrl.text.trim(),
                  'subjectName': subjectCtrl.text.trim(),
                  'batchName': batchCtrl.text.trim(),
                  'teacherName': teacherCtrl.text.trim(),
                  'zoomLink': linkCtrl.text.trim(),
                  'recordingLink': recordingCtrl.text.trim(),
                  'durationMinutes': selectedDuration,
                  'date': dateStr,
                  'time': timeStr,
                  'scheduledDateTime': scheduledDateTime.toIso8601String(),
                  'createdAt': DateTime.now().toIso8601String(),
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class published with scheduled date & time!')),
                  );
                }
              },
              child: const Text('Schedule Class'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final titleCtrl = TextEditingController(text: data['classTitle'] ?? '');
    final linkCtrl = TextEditingController(text: data['zoomLink'] ?? '');
    final teacherCtrl = TextEditingController(text: data['teacherName'] ?? '');
    int duration = data['durationMinutes'] ?? 60;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Class Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Class Title')),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: teacherCtrl.text.isNotEmpty ? teacherCtrl.text : null,
                  decoration: const InputDecoration(labelText: 'Assigned Teacher'),
                  items: docs.map((d) {
                    final tdata = d.data() as Map<String, dynamic>;
                    final tname = tdata['name'] ?? d.id;
                    return DropdownMenuItem<String>(value: tname, child: Text(tname));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) teacherCtrl.text = val;
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'Zoom Link')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('classes').doc(doc.id).update({
                'classTitle': titleCtrl.text.trim(),
                'teacherName': teacherCtrl.text.trim(),
                'zoomLink': linkCtrl.text.trim(),
                'durationMinutes': duration,
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class session updated!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClass(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel / Delete Class?'),
        content: const Text('Are you sure you want to delete this scheduled class session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('classes').doc(doc.id).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class deleted successfully.')),
                );
              }
            },
            child: const Text('Delete Session'),
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
        title: const Text('Class Schedules & Live Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF7C3AED),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            tooltip: 'Schedule Class',
            onPressed: () => _showAddClassDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.video_call),
        label: const Text('Schedule Class'),
        onPressed: () => _showAddClassDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('classes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No classes scheduled in Firestore.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['classTitle'] ?? 'Live Session';
              final subject = data['subjectName'] ?? 'General Subject';
              final teacher = data['teacherName'] ?? 'Lecturer';
              final batch = data['batchName'] ?? 'All Batches';
              final duration = data['durationMinutes'] ?? 60;
              final zoomLink = data['zoomLink'] ?? '';
              final dateStr = data['date'] ?? 'Today';

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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subject,
                            style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Color(0xFF7C3AED)),
                              tooltip: 'Edit Class',
                              onPressed: () => _showEditClassDialog(context, doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                              tooltip: 'Delete Class',
                              onPressed: () => _confirmDeleteClass(context, doc),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Instructor: $teacher • Batch: $batch • $duration mins ($dateStr)',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.videocam, size: 16),
                        label: const Text('Test / Join Zoom Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 5: ACADEMIC BATCHES MANAGEMENT (CRUD)
// ─────────────────────────────────────────────────────────────
class AdminManageBatchesTab extends StatefulWidget {
  const AdminManageBatchesTab({super.key});

  @override
  State<AdminManageBatchesTab> createState() => _AdminManageBatchesTabState();
}

class _AdminManageBatchesTabState extends State<AdminManageBatchesTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBatchDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.class_, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text('Create Academic Batch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Batch Name *',
                  hintText: 'e.g. 2026 A/L Science & Maths',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Batch Code *',
                  hintText: 'e.g. 2026-AL-SCI',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description / Curriculum',
                  hintText: 'e.g. Advanced Level Physical & Bio Science',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Batch Name and Code are required.')),
                );
                return;
              }
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('batches').add({
                'name': nameCtrl.text.trim(),
                'code': codeCtrl.text.trim().toUpperCase(),
                'description': descCtrl.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Academic batch created successfully!')),
                );
              }
            },
            child: const Text('Create Batch'),
          ),
        ],
      ),
    );
  }

  void _showEditBatchDialog(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final codeCtrl = TextEditingController(text: data['code'] ?? '');
    final descCtrl = TextEditingController(text: data['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Academic Batch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Batch Code *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('batches').doc(doc.id).update({
                'name': nameCtrl.text.trim(),
                'code': codeCtrl.text.trim().toUpperCase(),
                'description': descCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Academic batch updated successfully!')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBatch(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Batch';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Academic Batch?'),
        content: Text('Are you sure you want to delete "$name"? Students enrolled in this batch may need to be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('batches').doc(doc.id).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Academic batch removed successfully.')),
                );
              }
            },
            child: const Text('Delete Batch'),
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
        title: const Text('Academic Batches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFD97706),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Batch',
            onPressed: () => _showAddBatchDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Batch'),
        onPressed: () => _showAddBatchDialog(context),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search batches by name or code...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('batches').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final code = (data['code'] ?? '').toString().toLowerCase();
                  final desc = (data['description'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || code.contains(_searchQuery) || desc.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No Academic Batches Found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap "+ Add Batch" to create an academic stream or grade batch.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Academic Batch';
                    final code = data['code'] ?? 'BATCH';
                    final description = data['description'] ?? 'Enrolled curriculum';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFEF3C7),
                            child: const Icon(Icons.class_, color: Color(0xFFD97706), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        code,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  description.isNotEmpty ? description : 'Active Academic Batch',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFFD97706)),
                                tooltip: 'Edit',
                                onPressed: () => _showEditBatchDialog(context, doc),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDeleteBatch(context, doc),
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
