import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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

      return await _saveFile(
        image.path,
        FileSource.camera,
      );
    } catch (e) {
      print('Error picking from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<FileMetadata?> pickFromGallery() async {
    return _pickSingleFile();
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
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Scan document using camera
  Future<List<FileMetadata>> scanDocument() async {
    try {
      final List<String>? scannedPaths = await CunningDocumentScanner.getPictures(
        noOfPages: 5,
      );

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
    } catch (e) {
      print('Error scanning document: $e');
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
      );
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  /// Save file to app directory
  Future<FileMetadata?> _saveFile(String sourcePath, FileSource source) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');
      
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final File sourceFile = File(sourcePath);
      final String extension = p.extension(sourcePath);
      final String fileId = _uuid.v4();
      final String fileName = '$fileId$extension';
      final String targetPath = '${mediaDir.path}/$fileName';

      await sourceFile.copy(targetPath);

      final fileSize = await File(targetPath).length();

      return FileMetadata(
        id: fileId,
        path: targetPath,
        fileName: fileName,
        source: source,
        createdAt: DateTime.now(),
        fileSize: fileSize,
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
}
