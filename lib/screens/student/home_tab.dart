import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class HomeTab extends StatelessWidget {
  final void Function(int index)? onNavigateTab;

  const HomeTab({super.key, this.onNavigateTab});

  Future<void> _launchZoom(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meeting link provided for this class.')),
      );
      return;
    }
    final uri = Uri.parse(url.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Zoom link on this device.')),
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
          'Are you sure you want to sign out of the Wisdom Student Portal?',
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Wisdom Student Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // StreamBuilders automatically react to Firestore updates
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO STUDENT WELCOME CARD (Live Firestore profile)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  final name = data?['name'] ?? currentUser?.displayName ?? 'Student';
                  final studentId = data?['studentId'] ?? 'STU-ONLINE';
                  final email = data?['email'] ?? currentUser?.email ?? '';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome back,',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ID: $studentId • $email',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 3 Live Quick Stats Row
                        Row(
                          children: [
                            // Stat 1: Live Attendance %
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('attendance')
                                    .where('studentUid', isEqualTo: uid)
                                    .snapshots(),
                                builder: (context, attSnap) {
                                  final docs = attSnap.data?.docs ?? [];
                                  if (docs.isEmpty) {
                                    return _buildMiniStat(
                                      title: 'Attendance',
                                      value: '100%',
                                      subtitle: 'Perfect Record',
                                      icon: Icons.check_circle_outline,
                                    );
                                  }
                                  final present = docs.where((d) {
                                    final m = d.data() as Map<String, dynamic>;
                                    return m['status'] == 'present';
                                  }).length;
                                  final pct = ((present / docs.length) * 100).round();
                                  return _buildMiniStat(
                                    title: 'Attendance',
                                    value: '$pct%',
                                    subtitle: '$present of ${docs.length} sessions',
                                    icon: Icons.how_to_reg,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Stat 2: Pending Tasks
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('assignments')
                                    .where('isPending', isEqualTo: true)
                                    .snapshots(),
                                builder: (context, assignSnap) {
                                  final count = assignSnap.data?.docs.length ?? 0;
                                  return _buildMiniStat(
                                    title: 'Pending Tasks',
                                    value: '$count',
                                    subtitle: count == 0 ? 'All Complete' : 'Due this week',
                                    icon: Icons.assignment_outlined,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Stat 3: Scheduled Classes
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('classes').snapshots(),
                                builder: (context, classSnap) {
                                  final count = classSnap.data?.docs.length ?? 0;
                                  return _buildMiniStat(
                                    title: 'Live Classes',
                                    value: '$count',
                                    subtitle: 'Available',
                                    icon: Icons.video_call_outlined,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        // Monthly Fee Status Card Banner
                        Builder(
                          builder: (context) {
                            final feeStatus = data?['feeStatus'] ?? 'Paid';
                            final feeMonth = data?['feeMonth'] ?? 'October 2026';
                            final isPaid = feeStatus == 'Paid';

                            return Container(
                              margin: const EdgeInsets.only(top: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFFFEF2F2).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isPaid ? Colors.white24 : const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPaid ? Icons.verified_user_rounded : Icons.info_outline,
                                    size: 18,
                                    color: isPaid ? const Color(0xFF86EFAC) : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isPaid
                                          ? 'Tuition Card: ACTIVE ($feeMonth Paid) • Full Class Access'
                                          : 'Tuition Fee Due for $feeMonth • Please verify with Admin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? Colors.white : const Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. QUICK ACTIONS
              const Text(
                'Quick Navigation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickActionButton(
                    context,
                    title: 'Live Zoom',
                    icon: Icons.video_camera_front,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    onTap: () => onNavigateTab?.call(1),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionButton(
                    context,
                    title: 'Assignments',
                    icon: Icons.assignment,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                    onTap: () => onNavigateTab?.call(2),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionButton(
                    context,
                    title: 'Attendance',
                    icon: Icons.how_to_reg,
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    onTap: () => onNavigateTab?.call(3),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionButton(
                    context,
                    title: 'My Profile',
                    icon: Icons.person,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                    onTap: () => onNavigateTab?.call(4),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. LIVE & UPCOMING CLASSES SECTION (REAL FIRESTORE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live & Upcoming Classes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () => onNavigateTab?.call(1),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
                builder: (context, studentSnap) {
                  final sdata = studentSnap.data?.data() as Map<String, dynamic>?;
                  final feeStatus = sdata?['feeStatus'] ?? 'Paid';
                  final feeMonth = sdata?['feeMonth'] ?? 'Current Month';
                  final isPaid = feeStatus == 'Paid';

                  final enrolledBatches = <String>[];
                  if (sdata?['enrolledBatches'] is List) {
                    for (final b in (sdata!['enrolledBatches'] as List)) {
                      if (b != null && b.toString().trim().isNotEmpty) {
                        enrolledBatches.add(b.toString().trim().toLowerCase());
                      }
                    }
                  }
                  final singleBatch = (sdata?['batch'] ?? sdata?['batchName'])?.toString().trim();
                  if (singleBatch != null && singleBatch.isNotEmpty && !enrolledBatches.contains(singleBatch.toLowerCase())) {
                    enrolledBatches.add(singleBatch.toLowerCase());
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('classes').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      final docs = allDocs.where((doc) {
                        final c = doc.data() as Map<String, dynamic>;
                        final classBatch = (c['batchName'] ?? '').toString().trim();
                        if (classBatch.isEmpty ||
                            classBatch.toLowerCase() == 'all batches' ||
                            classBatch.toLowerCase() == 'all enrolled batches' ||
                            classBatch.toLowerCase() == 'enrolled students' ||
                            enrolledBatches.isEmpty) {
                          return true;
                        }
                        return enrolledBatches.contains(classBatch.toLowerCase());
                      }).toList();

                      if (docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.event_available, size: 40, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              const Text(
                                'No live classes scheduled currently.',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                enrolledBatches.isNotEmpty
                                    ? 'Sessions scheduled for your batch will appear here.'
                                    : 'Your educator will schedule upcoming sessions here.',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        );
                      }

                      // Take top 2 classes
                      final topClasses = docs.take(2).toList();
                      return Column(
                        children: topClasses.map((doc) {
                          final c = doc.data() as Map<String, dynamic>;
                          final title = c['classTitle'] ?? 'Live Classroom Session';
                          final batch = c['batchName'] ?? 'All Enrolled Batches';
                          final subject = c['subjectName'] ?? 'General Subject';
                          final teacher = c['teacherName'] ?? 'Teacher';
                          final duration = c['durationMinutes'] ?? 60;
                          final zoomLink = c['zoomLink'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPaid ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
                              ),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        subject.toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF1E40AF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 3,
                                            backgroundColor: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isPaid ? 'LIVE ONLINE' : 'FEE DUE • LOCKED',
                                            style: TextStyle(
                                              color: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Instructor: $teacher • Batch: $batch • $duration mins',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 12),
                                if (isPaid)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      icon: const Icon(Icons.videocam, size: 18),
                                      label: const Text(
                                        'Join Zoom Class Now',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () => _launchZoom(context, zoomLink),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFECACA)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.lock_rounded, size: 18, color: Color(0xFFDC2626)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Tuition fee for $feeMonth is pending. Settle fee at reception to unlock live Zoom meeting.',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // 4. ACTIVE ASSIGNMENTS SECTION (REAL FIRESTORE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Homework & Tasks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () => onNavigateTab?.call(2),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assignments')
                    .where('isPending', isEqualTo: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No pending assignments. You are completely up to date!',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((d) {
                      final task = d.data() as Map<String, dynamic>;
                      final title = task['title'] ?? 'Assignment';
                      final subject = task['subject'] ?? 'General';
                      final dueDate = task['dueDate'] ?? 'This Week';
                      final points = task['totalPoints'] ?? 100;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.assignment_outlined, color: Color(0xFFD97706)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$subject • Due: $dueDate • $points Pts',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => onNavigateTab?.call(2),
                              child: const Text('Open', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: bgColor,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
