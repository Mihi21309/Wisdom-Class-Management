import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wisdom_class_management/models/attendance.dart';
import 'package:wisdom_class_management/models/batch.dart';
import 'package:wisdom_class_management/models/subject.dart';
import 'package:wisdom_class_management/services/firebase_service.dart';
import 'package:wisdom_class_management/services/student_service.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late final StudentService _studentService;
  late final FirebaseService _firebaseService;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _studentService = StudentService();
    _firebaseService = FirebaseService();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _firebaseService.currentUserUid;

    if (currentUserUid == null) {
      return const Center(child: Text('Please log in to view your attendance'));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Month Selector
            _buildMonthSelector(),
            const SizedBox(height: 24),

            // Attendance by Batch
            StreamBuilder<List<Batch>>(
              stream: _studentService.streamEnrolledBatches(currentUserUid),
              builder: (context, batchSnapshot) {
                final batches = batchSnapshot.data ?? [];

                if (batches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No attendance records',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: batches.map((batch) {
                    return _buildBatchAttendance(batch, currentUserUid);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthYear = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                monthYear,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe or tap arrows to change month',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchAttendance(Batch batch, String currentUserUid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Batch Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<Map<String, double>>(
                        future: _studentService.getAttendanceStats(
                          currentUserUid,
                          batch.id,
                        ),
                        builder: (context, snapshot) {
                          final stats = snapshot.data ?? {};
                          final percentage = stats['percentage'] ?? 0;
                          return Text(
                            'Overall: ${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Attendance Records
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Attendance>>(
              future: _studentService.getAttendanceByBatchAndMonth(
                currentUserUid,
                batch.id,
                _selectedMonth.month,
                _selectedMonth.year,
              ),
              builder: (context, snapshot) {
                final attendanceRecords = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (attendanceRecords.isEmpty) {
                  return Center(
                    child: Text(
                      'No attendance records for this month',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  );
                }

                // Group by subject
                final recordsBySubject = <String, List<Attendance>>{};
                for (final record in attendanceRecords) {
                  recordsBySubject
                      .putIfAbsent(record.subjectId, () => [])
                      .add(record);
                }

                return Column(
                  children: recordsBySubject.entries.map((entry) {
                    final subjectId = entry.key;
                    final records = entry.value;

                    return _buildSubjectAttendanceSection(
                      subjectId: subjectId,
                      records: records,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectAttendanceSection({
    required String subjectId,
    required List<Attendance> records,
  }) {
    return FutureBuilder<Subject?>(
      future: _studentService.getSubjectById(subjectId),
      builder: (context, snapshot) {
        final subject = snapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subject != null) ...[
              Text(
                subject.name,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: records.map((record) {
                  return _buildAttendanceRecord(record);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildAttendanceRecord(Attendance record) {
    final statusColor = record.status == AttendanceStatus.present
        ? Colors.green
        : record.status == AttendanceStatus.leave
        ? Colors.orange
        : Colors.red;
    final statusLabel = record.status.label;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.1),
              border: Border.all(color: statusColor),
            ),
            child: Center(
              child: Icon(
                record.status == AttendanceStatus.present
                    ? Icons.check
                    : record.status == AttendanceStatus.leave
                    ? Icons.info
                    : Icons.close,
                color: statusColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(record.date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  statusLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
