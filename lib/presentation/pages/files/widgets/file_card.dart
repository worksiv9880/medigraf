import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:medigraf/data/datasources/local/app_database.dart';

class FileCard extends StatelessWidget {
  final DbFile file;
  final Participant? participant;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FileCard({
    super.key,
    required this.file,
    this.participant,
    this.onShare,
    this.onEdit,
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

  List<Widget> _buildActions(ThemeData theme) {
    final actionBackground = theme.colorScheme.surfaceVariant;
    final outline = theme.colorScheme.outlineVariant;
    final onSurface = theme.colorScheme.onSurface.withOpacity(0.8);
    final actions = <Widget>[];

    if (onShare != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onShare?.call(),
          backgroundColor: actionBackground,
          foregroundColor: onSurface,
          icon: Icons.share,
          label: 'Share',
        ),
      );
    }
    if (onEdit != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onEdit?.call(),
          backgroundColor: actionBackground,
          foregroundColor: onSurface,
          icon: Icons.edit,
          label: 'Edit',
        ),
      );
    }
    if (onDelete != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onDelete?.call(),
          backgroundColor: actionBackground,
          foregroundColor: onSurface,
          icon: Icons.delete,
          label: 'Delete',
        ),
      );
    }

    for (var i = 0; i < actions.length; i++) {
      final isFirst = i == 0;
      actions[i] = DecoratedBox(
        decoration: BoxDecoration(
          color: actionBackground,
          border: Border(
            left: isFirst ? BorderSide(color: outline) : BorderSide.none,
            right: BorderSide(color: outline),
            top: BorderSide(color: outline),
            bottom: BorderSide(color: outline),
          ),
        ),
        child: actions[i],
      );
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final outlineColor = theme.colorScheme.outlineVariant;
    final badgeTextColor = theme.colorScheme.onSurface.withOpacity(0.75);
    final formattedDate = DateFormat('dd.MM.yyyy').format(file.fileDate);
    final typeLabel = _resolveTypeLabel(file.type);
    final typeIcon = _resolveTypeIcon(file.type);

    final actions = _buildActions(theme);

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
              color: cardColor,
              border: Border.all(color: outlineColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: badgeTextColor),
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
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineColor),
                              ),
                              child: Text(
                                '${participant!.emoji} ${participant!.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: badgeTextColor,
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
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: outlineColor),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: badgeTextColor,
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
