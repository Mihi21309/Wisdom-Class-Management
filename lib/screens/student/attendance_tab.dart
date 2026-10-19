import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  int _filterIndex = 0; // 0: All, 1: Present, 2: Absent

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Attendance Records',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data?.docs ?? [];
          // Filter records matching current student (either studentUid or studentId)
          final studentRecords = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final recUid = data['studentUid'] ?? data['studentId'] ?? '';
            // If specific match or fallback if universal session
            return recUid == uid || recUid.toString().contains(uid);
          }).toList();

          // Calculate attendance metrics
          final totalCount = studentRecords.length;
          final presentCount = studentRecords.where((d) {
            final m = d.data() as Map<String, dynamic>;
            return (m['status'] ?? '').toString().toLowerCase() == 'present';
          }).length;
          final absentCount = totalCount - presentCount;
          final percentage = totalCount > 0 ? ((presentCount / totalCount) * 100).round() : 100;

          // Filter by selected tab
          final displayedRecords = studentRecords.where((d) {
            final m = d.data() as Map<String, dynamic>;
            final status = (m['status'] ?? '').toString().toLowerCase();
            if (_filterIndex == 1) return status == 'present';
            if (_filterIndex == 2) return status == 'absent';
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ATTENDANCE SUMMARY HERO CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overall Attendance Rate',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: percentage >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: percentage >= 80 ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: percentage >= 80 ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  percentage >= 80 ? Icons.verified : Icons.warning_amber,
                                  size: 16,
                                  color: percentage >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  percentage >= 80 ? 'Exam Eligible' : 'Needs Attention',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: percentage >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalCount > 0 ? (presentCount / totalCount) : 1.0,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Metric Pills
                      Row(
                        children: [
                          _buildMetricItem('Total Sessions', '$totalCount', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                          const SizedBox(width: 8),
                          _buildMetricItem('Present', '$presentCount', const Color(0xFF059669), const Color(0xFFECFDF5)),
                          const SizedBox(width: 8),
                          _buildMetricItem('Absent', '$absentCount', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. FILTER TABS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Session History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFilterPill('All', 0),
                          const SizedBox(width: 6),
                          _buildFilterPill('Present', 1),
                          const SizedBox(width: 6),
                          _buildFilterPill('Absent', 2),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. ATTENDANCE LOG LIST
                if (displayedRecords.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.event_note, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text(
                          'No attendance logs found for this filter.',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Attendance marked by your lecturers will appear here automatically.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedRecords.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final rec = displayedRecords[i].data() as Map<String, dynamic>;
                      final status = (rec['status'] ?? 'present').toString().toLowerCase();
                      final isPresent = status == 'present';
                      final classId = rec['classTitle'] ?? rec['topic'] ?? rec['className'] ?? rec['classId'] ?? 'Live Session';
                      final subject = (rec['subjectName'] ?? rec['subject'] ?? rec['subjectId'] ?? 'General Subject').toString();
                      final dateStr = rec['date'] ?? 'Recent Session';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isPresent
                                        ? const Color(0xFF059669).withValues(alpha: 0.12)
                                        : const Color(0xFFDC2626).withValues(alpha: 0.12),
                                    child: Icon(
                                      isPresent ? Icons.check : Icons.close,
                                      size: 18,
                                      color: isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject.replaceAll('_', ' ').toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Session: $classId • Date: $dateStr',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPresent ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPresent ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Text(
                                isPresent ? 'PRESENT' : 'ABSENT',
                                style: TextStyle(
                                  color: isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, int index) {
    final isSelected = _filterIndex == index;
    return InkWell(
      onTap: () => setState(() => _filterIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
