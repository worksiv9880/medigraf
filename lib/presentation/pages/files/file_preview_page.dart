import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart';
import 'package:medigraf/data/datasources/local/app_database.dart';

class FilePreviewPage extends StatefulWidget {
  const FilePreviewPage({
    super.key,
    required this.file,
    required this.participant,
    required this.onEditMetadata,
    required this.onDelete,
    required this.onShare,
  });

  final DbFile file;
  final Participant? participant;
  final Future<bool> Function(DbFile file) onEditMetadata;
  final Future<bool> Function(DbFile file) onDelete;
  final Future<void> Function(DbFile file) onShare;

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  PdfControllerPinch? _pdfController;
  final TransformationController _imageController = TransformationController();
  bool _pdfLoadFailed = false;
  bool _imageLoadFailed = false;

  @override
  void initState() {
    super.initState();
    if (_isPdf(widget.file.filePath)) {
      try {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(widget.file.filePath),
        );
      } catch (_) {
        _pdfLoadFailed = true;
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _imageController.dispose();
    super.dispose();
  }

  bool _isPdf(String path) => p.extension(path).toLowerCase() == '.pdf';

  bool _isImage(String path) {
    const extensions = {
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.tif',
      '.tiff',
      '.webp',
      '.heic',
      '.heif',
    };
    return extensions.contains(p.extension(path).toLowerCase());
  }

  String _formatType(String type) {
    const labels = {
      'LAB_RESULTS': 'Lab results',
      'IMAGING': 'Imaging',
      'PRESCRIPTIONS': 'Prescriptions',
      'VACCINATIONS': 'Vaccinations',
      'REFERRALS': 'Referrals',
      'VISIT_NOTES': 'Visit / Clinical notes',
      'ADMINISTRATIVE': 'Administrative / Insurance',
      'RECEIPT': 'Receipt',
      'OTHER': 'Other',
    };

    return labels[type] ?? type.replaceAll('_', ' ');
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '—';
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    }
    if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  String _formatDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

  Future<void> _showMoreActions() async {
    final action = await showModalBottomSheet<_PreviewAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => Navigator.of(context).pop(_PreviewAction.share),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit metadata'),
              onTap: () => Navigator.of(context).pop(_PreviewAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.of(context).pop(_PreviewAction.delete),
            ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _PreviewAction.share:
        await widget.onShare(widget.file);
        break;
      case _PreviewAction.edit:
        final updated = await widget.onEditMetadata(widget.file);
        if (updated && mounted) {
          Navigator.of(context).pop(true);
        }
        break;
      case _PreviewAction.delete:
        final deleted = await widget.onDelete(widget.file);
        if (deleted && mounted) {
          Navigator.of(context).pop(true);
        }
        break;
    }
  }

  Future<void> _handleShare() async {
    await widget.onShare(widget.file);
  }

  void _toggleImageZoom() {
    final currentScale = _imageController.value.getMaxScaleOnAxis();
    if (currentScale > 1.0) {
      _imageController.value = Matrix4.identity();
    } else {
      _imageController.value = Matrix4.identity()..scale(2.5);
    }
  }

  Widget _buildPreviewContent(ThemeData theme) {
    if (_isPdf(widget.file.filePath) && !_pdfLoadFailed) {
      return Container(
        color: Colors.white,
        child: PdfViewPinch(
          controller: _pdfController!,
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          onDocumentError: (_) {
            if (mounted) {
              setState(() => _pdfLoadFailed = true);
            }
          },
          onPageError: (_, __) {
            if (mounted) {
              setState(() => _pdfLoadFailed = true);
            }
          },
        ),
      );
    }

    if (_isImage(widget.file.filePath) && !_imageLoadFailed) {
      return Container(
        color: Colors.black,
        child: Center(
          child: GestureDetector(
            onDoubleTap: _toggleImageZoom,
            child: InteractiveViewer(
              transformationController: _imageController,
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                File(widget.file.filePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _imageLoadFailed = true);
                    }
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              widget.file.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _formatSize(widget.file.fileSize),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => OpenFilex.open(widget.file.filePath),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open with…'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.calendar_today,
                label: _formatDate(widget.file.fileDate),
              ),
              _InfoPill(
                icon: Icons.receipt_long,
                label: _formatType(widget.file.type),
              ),
            ],
          ),
          if (widget.participant != null) ...[
            const SizedBox(height: 8),
            _InfoPill(
              icon: Icons.person,
              label:
                  '${widget.participant!.emoji} ${widget.participant!.name}',
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          widget.file.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: _handleShare,
          ),
          IconButton(
            tooltip: 'More',
            icon: const Icon(Icons.more_horiz),
            onPressed: _showMoreActions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreviewContent(theme)),
          _buildMetadataBar(theme),
        ],
      ),
    );
  }
}

enum _PreviewAction { share, edit, delete }

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
