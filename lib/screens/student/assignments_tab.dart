import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: Completed

  final List<Map<String, dynamic>> _mockAssignments = [
    {
      'title': 'Differential Calculus Problem Set 04',
      'subject': 'Combined Mathematics',
      'teacher': 'Mr. K. Perera',
      'dueDate': 'Tomorrow, 11:59 PM',
      'isPending': true,
      'score': null,
      'totalPoints': 100,
    },
    {
      'title': 'Electromagnetism Lab Report',
      'subject': 'Physics',
      'teacher': 'Dr. Silva',
      'dueDate': 'Oct 24, 2026',
      'isPending': true,
      'score': null,
      'totalPoints': 50,
    },
    {
      'title': 'Complex Numbers Revision Test',
      'subject': 'Combined Mathematics',
      'teacher': 'Mr. K. Perera',
      'dueDate': 'Completed',
      'isPending': false,
      'score': 92,
      'totalPoints': 100,
    },
    {
      'title': 'Organic Chemistry Reaction Mechanisms',
      'subject': 'Chemistry',
      'teacher': 'Mrs. Fernando',
      'dueDate': 'Completed',
      'isPending': false,
      'score': 85,
      'totalPoints': 100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _mockAssignments.where((item) {
      if (_selectedFilterIndex == 1) return item['isPending'] == true;
      if (_selectedFilterIndex == 2) return item['isPending'] == false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assignments & Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_mockAssignments.where((a) => a['isPending'] == true).length} Pending',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('All', 0),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 1),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', 2),
                    ],
                  ),
                ],
              ),
            ),

            // Assignments List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined,
                              size: 56, color: Colors.grey.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          const Text(
                            'No assignments found',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final isPending = item['isPending'] as bool;

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isPending
                                          ? Icons.schedule_rounded
                                          : Icons.check_circle_outline_rounded,
                                      color: isPending
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF059669),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${item['subject']} • ${item['teacher']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.event_outlined,
                                          size: 15, color: Color(0xFF64748B)),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Due: ${item['dueDate']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isPending
                                              ? const Color(0xFFE11D48)
                                              : const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isPending)
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('File submission portal opened'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: const Text('Submit Work',
                                          style: TextStyle(fontSize: 12)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0xFFA7F3D0)),
                                      ),
                                      child: Text(
                                        'Grade: ${item['score']}/${item['totalPoints']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
