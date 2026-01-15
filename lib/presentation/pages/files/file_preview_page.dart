import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool _fileMissing = false;
  bool _pdfLoadFailed = false;
  bool _imageLoadFailed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  Future<void> _initPreview() async {
    final path = widget.file.filePath;
    final file = File(path);

    // 1) проверка существования
    final exists = await file.exists();
    if (!exists) {
      if (mounted) {
        setState(() {
          _fileMissing = true;
          _loading = false;
        });
      }
      return;
    }

    // 2) инициализация контента
    try {
      if (_isPdf(path)) {
        // ✅ На iOS это надежнее, чем openFile()
        final Uint8List bytes = await file.readAsBytes();
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(bytes),
        );
      }
    } catch (_) {
      _pdfLoadFailed = true;
    }

    if (mounted) {
      setState(() => _loading = false);
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
    if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
    if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
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
              title: const Text('Edit'),
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
        if (updated && mounted) Navigator.of(context).pop(true);
        break;
      case _PreviewAction.delete:
        final deleted = await widget.onDelete(widget.file);
        if (deleted && mounted) Navigator.of(context).pop(true);
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

  Widget _buildCenteredMessage(ThemeData theme,
      {required IconData icon, required String title, String? subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_fileMissing) {
      return _buildCenteredMessage(
        theme,
        icon: Icons.folder_off,
        title: 'Файл не найден',
        subtitle: 'Путь: ${widget.file.filePath}',
      );
    }

    final path = widget.file.filePath;

    // PDF
    if (_isPdf(path)) {
      if (_pdfLoadFailed || _pdfController == null) {
        return _buildCenteredMessage(
          theme,
          icon: Icons.picture_as_pdf,
          title: 'Не удалось открыть PDF',
          subtitle: _formatSize(widget.file.fileSize),
        );
      }

      return Container(
        color: Colors.white,
        child: PdfViewPinch(
          controller: _pdfController!,
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          onDocumentError: (_) {
            if (mounted) setState(() => _pdfLoadFailed = true);
          },
        ),
      );
    }

    // Image
    if (_isImage(path)) {
      if (_imageLoadFailed) {
        return _buildCenteredMessage(
          theme,
          icon: Icons.broken_image,
          title: 'Не удалось открыть изображение',
          subtitle: _formatSize(widget.file.fileSize),
        );
      }

      return Container(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: GestureDetector(
              onDoubleTap: _toggleImageZoom,
              child: InteractiveViewer(
                transformationController: _imageController,
                minScale: 1,
                maxScale: 4,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // ✅ вместо "пустоты" покажем fallback
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _imageLoadFailed = true);
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fallback для прочих файлов
    return _buildCenteredMessage(
      theme,
      icon: Icons.insert_drive_file,
      title: widget.file.title,
      subtitle: _formatSize(widget.file.fileSize),
    );
  }

  Widget _buildMetadataBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
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
              label: '${widget.participant!.emoji} ${widget.participant!.name}',
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
