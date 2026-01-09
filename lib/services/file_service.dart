import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

enum FileSource { camera, gallery, scanner, filePicker }

class FileMetadata {
  final String id;
  final String path;
  final String fileName;
  final FileSource source;
  final DateTime createdAt;
  final int? fileSize;
  final String? mimeType;
  final String? previewPath;
  final int? pageCount;

  FileMetadata({
    required this.id,
    required this.path,
    required this.fileName,
    required this.source,
    required this.createdAt,
    this.fileSize,
    this.mimeType,
    this.previewPath,
    this.pageCount,
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

      return await _saveFile(
        image.path,
        FileSource.camera,
        previewIsTarget: true,
        createdAt: await _getFileTimestamp(File(image.path)),
      );
    } catch (e) {
      print('Error picking from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<FileMetadata?> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveFile(
        image.path,
        FileSource.gallery,
        previewIsTarget: true,
        createdAt: await _getFileTimestamp(File(image.path)),
      );
    } catch (e) {
      print('Error picking from gallery: $e');
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
        final metadata = await _saveFile(
          image.path,
          FileSource.gallery,
          previewIsTarget: true,
          createdAt: await _getFileTimestamp(File(image.path)),
        );
        if (metadata != null) {
          files.add(metadata);
        }
      }

      return files;
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  Future<FileMetadata?> _pickSingleFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: _documentExtensions,
      );

      if (result == null || result.files.isEmpty) return null;
      final picked = result.files.single;
      if (picked.path == null) return null;

      return await _saveFile(
        picked.path!,
        FileSource.filePicker,
        mimeType: _inferMimeType(picked.extension),
        createdAt: await _getFileTimestamp(File(picked.path!)),
      );
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  Future<FileMetadata?> pickFromFileManager() async {
    return _pickSingleFile();
  }

  /// Launch document scanner and return captured image paths.
  Future<List<String>> scanDocumentRaw({
    int maxPages = 10,
    bool ensurePermission = true,
  }) async {
    try {
      if (ensurePermission) {
        final status = await requestCameraPermission();
        if (!status.isGranted) {
          print('Camera permission not granted');
          return [];
        }
      }

      final List<String>? scannedPaths = await CunningDocumentScanner.getPictures(
        noOfPages: maxPages,
      );

      return scannedPaths ?? [];
    } catch (e) {
      print('Error scanning document: $e');
      return [];
    }
  }

  /// Scan document and immediately save as PDF without user preview.
  Future<List<FileMetadata>> scanDocument({int maxPages = 10}) async {
    final scannedPaths = await scanDocumentRaw(maxPages: maxPages);
    if (scannedPaths.isEmpty) return [];

    final saved = await saveScannedPdf(scannedPaths: scannedPaths);
    return saved != null ? [saved] : [];
  }

  /// Convert scanned images into a single PDF and save.
  Future<FileMetadata?> saveScannedPdf({
    required List<String> scannedPaths,
  }) async {
    if (scannedPaths.isEmpty) return null;

    try {
      final firstPath = scannedPaths.first;
      final extension = p.extension(firstPath).isNotEmpty
          ? p.extension(firstPath)
          : '.jpg';
      return _saveFile(
        firstPath,
        FileSource.scanner,
        mimeType: _inferMimeType(extension.replaceAll('.', '')) ?? 'image/jpeg',
        previewIsTarget: true,
        pageCount: scannedPaths.length,
        createdAt: DateTime.now(),
        targetExtension: extension,
      );
    } catch (e) {
      print('Error saving scanned document: $e');
      return null;
    }
  }

  /// Save file to app directory
  Future<FileMetadata?> _saveFile(
    String sourcePath,
    FileSource source, {
    String? mimeType,
    String? previewSourcePath,
    bool previewIsTarget = false,
    int? pageCount,
    DateTime? createdAt,
    String? targetExtension,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');
      
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final File sourceFile = File(sourcePath);
      final String extension = targetExtension ?? p.extension(sourcePath);
      final String fileId = _uuid.v4();
      final String fileName = '$fileId$extension';
      final String targetPath = '${mediaDir.path}/$fileName';

      await sourceFile.copy(targetPath);

      final fileSize = await File(targetPath).length();
      String? previewPath;
      if (previewIsTarget) {
        previewPath = targetPath;
      } else if (previewSourcePath != null) {
        final thumbExt = p.extension(previewSourcePath).isNotEmpty
            ? p.extension(previewSourcePath)
            : extension;
        final thumbPath = '${mediaDir.path}/${fileId}_preview$thumbExt';
        await File(previewSourcePath).copy(thumbPath);
        previewPath = thumbPath;
      }

      final resolvedMime = mimeType ??
          _inferMimeType(extension.replaceAll('.', '')) ??
          _inferMimeType(p.extension(sourcePath).replaceAll('.', ''));
      final created = createdAt ?? await _getFileTimestamp(sourceFile);

      return FileMetadata(
        id: fileId,
        path: targetPath,
        fileName: fileName,
        source: source,
        createdAt: created,
        fileSize: fileSize,
        mimeType: resolvedMime,
        previewPath: previewPath,
        pageCount: pageCount,
      );
    } catch (e) {
      print('Error saving file: $e');
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
    } catch (e) {
      print('Error deleting file: $e');
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
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
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

  String? _inferMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'csv':
        return 'text/csv';
      case 'txt':
      case 'rtf':
        return 'text/plain';
      default:
        return null;
    }
  }

  Future<DateTime> _getFileTimestamp(File file) async {
    try {
      return await file.lastModified();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return status;
    return Permission.camera.request();
  }
}
