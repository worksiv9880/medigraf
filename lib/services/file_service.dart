import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

enum FileSource { camera, gallery, scanner, filePicker }

class FileMetadata {
  final String id;
  final String path;
  final String fileName;
  final FileSource source;
  final DateTime createdAt;
  final int? fileSize;

  FileMetadata({
    required this.id,
    required this.path,
    required this.fileName,
    required this.source,
    required this.createdAt,
    this.fileSize,
  });
}

class FileService {
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  static const List<String> _documentExtensions = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf',
    'csv',
    'xls',
    'xlsx',
    'jpg',
    'jpeg',
    'png',
    'heic',
    'heif',
    'bmp',
    'gif',
    'tiff',
    'tif',
    'webp',
  ];

  /// Pick image from camera
  Future<FileMetadata?> pickFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveFile(image.path, FileSource.camera);
    } catch (e, s) {
      debugPrint('Error picking from camera: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Pick image from gallery (single file picker)
  Future<FileMetadata?> pickFromGallery() async {
    return _pickSingleFile();
  }

  /// Pick a photo from gallery (ImagePicker)
  Future<FileMetadata?> pickPhotoFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveFile(image.path, FileSource.gallery);
    } catch (e, s) {
      debugPrint('Error picking photo from gallery: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<FileMetadata>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      final List<FileMetadata> files = [];
      for (final image in images) {
        final metadata = await _saveFile(image.path, FileSource.gallery);
        if (metadata != null) {
          files.add(metadata);
        }
      }

      return files;
    } catch (e, s) {
      debugPrint('Error picking multiple images: $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }

  /// Pick multiple files via FilePicker
  Future<List<FileMetadata>> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _documentExtensions,
        // ⚠️ можно включить, если хочешь надежнее с iCloud/provider:
        // withData: true,
      );

      if (result == null || result.files.isEmpty) return [];

      final List<FileMetadata> files = [];
      for (final picked in result.files) {
        final path = picked.path;
        if (path == null) continue;

        final metadata = await _saveFile(path, FileSource.filePicker);
        if (metadata != null) {
          files.add(metadata);
        }
      }

      return files;
    } catch (e, s) {
      debugPrint('Error picking multiple files: $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }

  /// Scan document using camera
  Future<List<FileMetadata>> scanDocument() async {
    try {
      final List<String>? scannedPaths =
          await CunningDocumentScanner.getPictures(noOfPages: 5);

      if (scannedPaths == null || scannedPaths.isEmpty) {
        return [];
      }

      final List<FileMetadata> files = [];
      for (final path in scannedPaths) {
        final metadata = await _saveFile(path, FileSource.scanner);
        if (metadata != null) {
          files.add(metadata);
        }
      }

      return files;
    } catch (e, s) {
      debugPrint('Error scanning document: $e');
      debugPrintStack(stackTrace: s);
      return [];
    }
  }

  Future<FileMetadata?> _pickSingleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: _documentExtensions,
        // withData: true,
      );

      if (result == null || result.files.isEmpty) return null;
      final picked = result.files.single;
      if (picked.path == null) return null;

      return await _saveFile(picked.path!, FileSource.filePicker);
    } catch (e, s) {
      debugPrint('Error picking file: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Save file to app Documents/media directory (robust)
  ///
  /// ✅ never returns metadata unless the destination file реально существует
  /// ✅ проверяет существование источника и результата копирования
  Future<FileMetadata?> _saveFile(String sourcePath, FileSource source) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(p.join(directory.path, 'media'));
      await mediaDir.create(recursive: true);

      final sourceFile = File(sourcePath);

      final srcExists = await sourceFile.exists();
      if (!srcExists) {
        debugPrint('SAVE FAIL: source not found: $sourcePath');
        return null;
      }

      // Иногда файл есть, но пустой/недоступен (provider)
      final srcSize = await sourceFile.length();
      if (srcSize == 0) {
        debugPrint('SAVE FAIL: source file size is 0: $sourcePath');
        return null;
      }

      final extension = p.extension(sourcePath);
      final fileId = _uuid.v4();
      final fileName = '$fileId$extension';
      final targetPath = p.join(mediaDir.path, fileName);

      // Важно: await обязательно
      final copiedFile = await sourceFile.copy(targetPath);

      final dstExists = await copiedFile.exists();
      final dstSize = dstExists ? await copiedFile.length() : 0;

      if (!dstExists || dstSize == 0) {
        debugPrint('SAVE FAIL: destination missing/empty: $targetPath');
        try {
          if (await copiedFile.exists()) {
            await copiedFile.delete();
          }
        } catch (_) {}
        return null;
      }

      debugPrint(
        'SAVE OK: src=$sourcePath ($srcSize B) -> dst=$targetPath ($dstSize B)',
      );

      return FileMetadata(
        id: fileId,
        path: targetPath,
        fileName: fileName,
        source: source,
        createdAt: DateTime.now(),
        fileSize: dstSize,
      );
    } catch (e, s) {
      debugPrint('Error saving file: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e, s) {
      debugPrint('Error deleting file: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  /// Get file size
  Future<int?> getFileSize(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e, s) {
      debugPrint('Error getting file size: $e');
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  /// Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
