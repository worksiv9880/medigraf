import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/file_service.dart';

Future<List<FileMetadata>> showFileSourcePicker(
  BuildContext context,
  FileService fileService, {
  bool allowMultipleFromGallery = false,
}) async {
  final source = await showModalBottomSheet<_PickerAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Select File Source',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text('Scan document'),
            subtitle: const Text('Camera with auto-detect and multi-page PDF'),
            onTap: () => Navigator.of(context).pop(_PickerAction.scan),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(_PickerAction.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Choose file'),
            subtitle: const Text('PDF, DOC, scans, and more'),
            onTap: () => Navigator.of(context).pop(_PickerAction.file),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (source == null) return [];

  switch (source) {
    case _PickerAction.scan:
      final scanned = await _handleScan(context, fileService);
      return scanned == null ? [] : [scanned];
    case _PickerAction.gallery:
      if (allowMultipleFromGallery) {
        return await fileService.pickMultipleFromGallery();
      }
      final fromGallery = await fileService.pickFromGallery();
      return fromGallery == null ? [] : [fromGallery];
    case _PickerAction.file:
      final fromFileManager = await fileService.pickFromFileManager();
      return fromFileManager == null ? [] : [fromFileManager];
  }
}

Future<FileMetadata?> _handleScan(
  BuildContext context,
  FileService fileService,
) async {
  final initialPages = await fileService.scanDocumentRaw(maxPages: 10);
  if (initialPages.isEmpty) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('No document scanned')),
    );
    return null;
  }

  final confirmedPages = await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ScanPreviewDialog(
      fileService: fileService,
      initialPages: initialPages,
    ),
  );

  if (confirmedPages == null || confirmedPages.isEmpty) return null;

  return fileService.saveScannedPdf(scannedPaths: confirmedPages);
}

class _ScanPreviewDialog extends StatefulWidget {
  const _ScanPreviewDialog({
    required this.fileService,
    required this.initialPages,
  });

  final FileService fileService;
  final List<String> initialPages;

  @override
  State<_ScanPreviewDialog> createState() => _ScanPreviewDialogState();
}

class _ScanPreviewDialogState extends State<_ScanPreviewDialog> {
  late List<String> _pages;
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pages = List.of(widget.initialPages);
  }

  Future<void> _retake() async {
    setState(() => _isLoading = true);
    final newPages = await widget.fileService.scanDocumentRaw();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (newPages.isNotEmpty) {
          _pages = newPages;
          _currentIndex = 0;
        }
      });
    }
  }

  Future<void> _addPages() async {
    setState(() => _isLoading = true);
    final additional = await widget.fileService.scanDocumentRaw();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (additional.isNotEmpty) {
          _pages.addAll(additional);
        }
      });
    }
  }

  void _useDocument() {
    Navigator.of(context).pop(_pages);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Preview scan'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 280,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      onPageChanged: (index) => setState(() => _currentIndex = index),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final path = _pages[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            if (!_isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Page ${_currentIndex + 1} of ${_pages.length}'),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _retake,
          child: const Text('Rescan'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _addPages,
          child: const Text('Add pages'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _useDocument,
          child: const Text('Use document'),
        ),
      ],
    );
  }
}

enum _PickerAction {
  scan,
  gallery,
  file,
}
