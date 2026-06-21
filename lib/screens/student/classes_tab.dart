import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisdom_class_management/models/batch.dart';
import 'package:wisdom_class_management/models/subject.dart';
import 'package:wisdom_class_management/models/zoom_class.dart';
import 'package:wisdom_class_management/services/firebase_service.dart';
import 'package:wisdom_class_management/services/student_service.dart';

class ClassesTab extends StatefulWidget {
  const ClassesTab({super.key});

  @override
  State<ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<ClassesTab> {
  late final StudentService _studentService;
  late final FirebaseService _firebaseService;
  final Set<String> _expandedBatches = {};

  @override
  void initState() {
    super.initState();
    _studentService = StudentService();
    _firebaseService = FirebaseService();
  }

  Future<void> _launchZoomLink(String zoomLink) async {
    final Uri url = Uri.parse(zoomLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Zoom link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = _firebaseService.currentUserUid;

    if (currentUserUid == null) {
      return const Center(child: Text('Please log in to view your classes'));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<List<Batch>>(
          stream: _studentService.streamEnrolledBatches(currentUserUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final batches = snapshot.data ?? [];

            if (batches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.class_, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No classes enrolled',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You haven\'t enrolled in any classes yet',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                final isExpanded = _expandedBatches.contains(batch.id);

                return _buildBatchCard(batch, isExpanded);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBatchCard(Batch batch, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedBatches.contains(batch.id)) {
                  _expandedBatches.remove(batch.id);
                } else {
                  _expandedBatches.add(batch.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Gradient banner icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        batch.name.isNotEmpty
                            ? batch.name
                                  .split(' ')
                                  .map((e) => e[0])
                                  .take(2)
                                  .join()
                            : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
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
                        Text(
                          '${batch.subjectsOffered.length} subjects • Year ${batch.year}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (batch.description.isNotEmpty) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      batch.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Subjects',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Subject>>(
                    future: _studentService.getSubjectsByIds(
                      batch.subjectsOffered,
                    ),
                    builder: (context, snapshot) {
                      final subjects = snapshot.data ?? [];

                      if (subjects.isEmpty) {
                        return Text(
                          'No subjects available',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        );
                      }

                      return Column(
                        children: subjects.map((subject) {
                          return _buildSubjectTile(subject, batch.id);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject, String batchId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teacher: ${subject.teacher}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<ZoomClass>>(
            stream: _studentService.streamZoomClassesForBatch(batchId),
            builder: (context, snapshot) {
              final allClasses = snapshot.data ?? [];
              final subjectClasses = allClasses
                  .where((zoomClass) => zoomClass.subjectId == subject.id)
                  .toList();

              if (subjectClasses.isEmpty) {
                return Text(
                  'No scheduled classes',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                );
              }

              return Column(
                children: subjectClasses.take(3).map((zoomClass) {
                  return _buildZoomClassTile(zoomClass);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZoomClassTile(ZoomClass zoomClass) {
    final status = zoomClass.isLive
        ? 'LIVE'
        : zoomClass.isUpcoming
        ? 'UPCOMING'
        : 'ENDED';
    final statusColor = zoomClass.isLive
        ? Colors.red
        : zoomClass.isUpcoming
        ? Colors.orange
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.video_call, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zoomClass.classTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${zoomClass.scheduledDateTime.hour}:${zoomClass.scheduledDateTime.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.open_in_new, size: 18),
              onPressed: (zoomClass.isUpcoming || zoomClass.isLive)
                  ? () => _launchZoomLink(zoomClass.zoomLink)
                  : null,
              tooltip: 'Join Zoom',
            ),
          ),
        ],
      ),
    );
  }
}
