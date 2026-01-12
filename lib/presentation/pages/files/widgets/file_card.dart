import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:medigraf/data/datasources/local/app_database.dart';

class FileCard extends StatelessWidget {
  final DbFile file;
  final Participant? participant;

  const FileCard({
    super.key,
    required this.file,
    this.participant,
  });

  IconData _resolveTypeIcon(String type) {
    final normalized = type.trim().toUpperCase();

    if (normalized.contains('VACCINATION')) {
      return Icons.vaccines;
    }
    if (normalized.contains('PRESCRIPTION')) {
      return Icons.medication;
    }
    if (normalized.contains('REFERRAL')) {
      return Icons.assignment_return;
    }
    if (normalized.contains('LAB') || normalized.contains('ANALYSIS')) {
      return Icons.science;
    }
    if (normalized.contains('IMAGING') ||
        normalized.contains('XRAY') ||
        normalized.contains('CT') ||
        normalized.contains('MRI') ||
        normalized.contains('US') ||
        normalized.contains('ULTRASOUND')) {
      return Icons.radar;
    }
    if (normalized.contains('NOTE') || normalized.contains('VISIT')) {
      return Icons.assignment;
    }
    if (normalized.contains('INSURANCE') ||
        normalized.contains('ADMIN') ||
        normalized.contains('BILL')) {
      return Icons.badge;
    }

    return Icons.insert_drive_file;
  }

  String _resolveTypeLabel(String type) {
    if (type.trim().isEmpty) {
      return 'GENERAL';
    }
    return type.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(file.fileDate);
    final typeLabel = _resolveTypeLabel(file.type);
    final typeIcon = _resolveTypeIcon(file.type);

    return InkWell(
      onTap: () {
        // OpenFile.open(file.filePath);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
    );
  }
}
