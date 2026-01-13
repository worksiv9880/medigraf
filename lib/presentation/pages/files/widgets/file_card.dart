import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:medigraf/data/datasources/local/app_database.dart';

class FileCard extends StatelessWidget {
  final DbFile file;
  final Participant? participant;
  final VoidCallback? onShare;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const FileCard({
    super.key,
    required this.file,
    this.participant,
    this.onShare,
    this.onRename,
    this.onDelete,
  });

  IconData _resolveTypeIcon(String type) {
    final normalized = type.trim().toUpperCase();
    const icons = {
      'LAB_RESULTS': Icons.science,
      'IMAGING': Icons.radar,
      'PRESCRIPTIONS': Icons.medication,
      'VACCINATIONS': Icons.vaccines,
      'REFERRALS': Icons.assignment_return,
      'VISIT_NOTES': Icons.assignment,
      'ADMINISTRATIVE': Icons.badge,
      'OTHER': Icons.insert_drive_file,
    };

    return icons[normalized] ?? Icons.insert_drive_file;
  }

  String _resolveTypeLabel(String type) {
    const labels = {
      'LAB_RESULTS': 'Lab results',
      'IMAGING': 'Imaging',
      'PRESCRIPTIONS': 'Prescriptions',
      'VACCINATIONS': 'Vaccinations',
      'REFERRALS': 'Referrals',
      'VISIT_NOTES': 'Visit / Clinical notes',
      'ADMINISTRATIVE': 'Administrative / Insurance',
      'OTHER': 'Other',
    };
    final normalized = type.trim().toUpperCase();
    return labels[normalized] ?? type.replaceAll('_', ' ');
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];

    if (onShare != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onShare?.call(),
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blueGrey.shade700,
          icon: Icons.share,
          label: 'Share',
        ),
      );
    }
    if (onRename != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onRename?.call(),
          backgroundColor: Colors.amber.shade50,
          foregroundColor: Colors.orange.shade800,
          icon: Icons.edit,
          label: 'Rename',
        ),
      );
    }
    if (onDelete != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onDelete?.call(),
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          icon: Icons.delete,
          label: 'Delete',
        ),
      );
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(file.fileDate);
    final typeLabel = _resolveTypeLabel(file.type);
    final typeIcon = _resolveTypeIcon(file.type);

    final actions = _buildActions();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(file.id),
        endActionPane: actions.isEmpty
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                children: actions,
              ),
        child: InkWell(
          onTap: () {
            // OpenFile.open(file.filePath);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              file.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (participant != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${participant!.emoji} ${participant!.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
