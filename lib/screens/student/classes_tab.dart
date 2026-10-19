import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchZoom(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Zoom link on this device.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Live Classes & Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.video_call_outlined, size: 20), text: 'Live Sessions'),
            Tab(icon: Icon(Icons.class_outlined, size: 20), text: 'Batches & Curriculum'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: LIVE SESSIONS (BATCH FILTERED & FEE GATED)
          _buildLiveSessionsList(context, uid),

          // TAB 2: ENROLLED BATCHES & CURRICULUM (FIRESTORE 'batches' & 'students')
          _buildBatchesAndCurriculum(context, uid),
        ],
      ),
    );
  }

  Widget _buildLiveSessionsList(BuildContext context, String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('students').doc(uid).snapshots(),
      builder: (context, studentSnap) {
        final sdata = studentSnap.data?.data() as Map<String, dynamic>?;
        final feeStatus = sdata?['feeStatus'] ?? 'Paid';
        final feeMonth = sdata?['feeMonth'] ?? 'Current Month';
        final isPaid = feeStatus == 'Paid';

        // Extract student's enrolled batches
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
              return const Center(child: CircularProgressIndicator());
            }

            final allDocs = snapshot.data?.docs ?? [];
            
            // Filter classes by enrolled batch
            final docs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final classBatch = (data['batchName'] ?? '').toString().trim();
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_camera_back_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No Scheduled Live Sessions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        enrolledBatches.isNotEmpty
                            ? 'When live classes are scheduled for your batch, they will appear here in real-time.'
                            : 'When your teachers schedule Zoom sessions, they will appear here in real-time.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final title = data['classTitle'] ?? 'Live Classroom Session';
                final batch = data['batchName'] ?? 'Enrolled Students';
                final subject = data['subjectName'] ?? 'Core Subject';
                final teacher = data['teacherName'] ?? 'Teacher';
                final zoomLink = data['zoomLink'] ?? '';
                final duration = data['durationMinutes'] ?? 60;
                final dateStr = data['date'] ?? 'Upcoming Today';
                final timeStr = data['time'] ?? 'Class Time';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPaid ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subject,
                              style: const TextStyle(
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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
                                  radius: 3.5,
                                  backgroundColor: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPaid ? 'READY TO JOIN' : 'FEE DUE • LOCKED',
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
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(teacher, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text('$duration mins ($timeStr)', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text('Batch: $batch • Date: $dateStr', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Fee-gated action buttons
                      if (isPaid) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.videocam, size: 18),
                                label: const Text('Join Zoom Meeting', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () => _launchZoom(context, zoomLink),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.copy, size: 18, color: Color(0xFF475569)),
                              tooltip: 'Copy Link',
                              onPressed: () {
                                if (zoomLink.isNotEmpty) {
                                  Clipboard.setData(ClipboardData(text: zoomLink));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Zoom link copied to clipboard!')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        if ((data['recordingLink'] ?? '').toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF7C3AED),
                                side: const BorderSide(color: Color(0xFF7C3AED)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.play_circle_fill, size: 18),
                              label: const Text('Watch Class Recording / Replay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () => _launchZoom(context, data['recordingLink']),
                            ),
                          ),
                        ],
                      ] else ...[
                        // Fee Due Locked Banner (Zoom link hidden)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lock_rounded, color: Color(0xFFDC2626), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Live Zoom Link Locked',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tuition fee for $feeMonth is pending. Please verify your payment at the reception or contact admin to unlock this live session.',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C), height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.lock_outline, size: 16),
                            label: Text(
                              'Tuition Fee Due for $feeMonth (Locked)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFDC2626),
                                  content: Text('Please settle tuition fee for $feeMonth to join this live Zoom meeting.'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBatchesAndCurriculum(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('batches').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No Batches Configured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Registered batches from Admin will appear here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final batch = docs[index].data() as Map<String, dynamic>;
            final name = batch['name'] ?? 'Academic Batch';
            final year = batch['year'] ?? 2026;
            final desc = batch['description'] ?? 'Wisdom Educational Unit Stream';
            final subjects = (batch['subjectsOffered'] as List?)?.cast<String>() ?? [];

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
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          name.isNotEmpty ? name[0] : 'B',
                          style: const TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Year: $year • ${subjects.length} Subjects Offered',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  ],
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: subjects.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF334155))),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
