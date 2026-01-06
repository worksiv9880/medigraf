import 'package:drift/drift.dart';
import '../../data/datasources/local/app_database.dart';
import 'file_service.dart';

class DbFileService {
  final AppDatabase db;
  final FileService fileService;

  DbFileService(this.db, this.fileService);

  Future<void> addFromCamera({
    required int participantId,
    required String title,
    required String type,
    DateTime? fileDate,
  }) async {
    final file = await fileService.pickFromCamera();
    if (file == null) return;

    await addFileWithMetadata(
      participantId: participantId,
      title: title,
      type: type,
      file: file,
      fileDate: fileDate,
    );
  }

  Future<void> addFromGallery({
    required int? participantId,
    required String title,
    required String type,
    DateTime? fileDate,
  }) async {
    final file = await fileService.pickFromGallery();
    if (file == null || participantId == null) return;

    await addFileWithMetadata(
      participantId: participantId,
      title: title,
      type: type,
      file: file,
      fileDate: fileDate,
    );
  }

  Future<void> addFromScanner({
    required int participantId,
    required String title,
    required String type,
    DateTime? fileDate,
  }) async {
    final files = await fileService.scanDocument();

    for (final file in files) {
      await addFileWithMetadata(
        participantId: participantId,
        title: title,
        type: type,
        file: file,
        fileDate: fileDate,
      );
    }
  }

  Future<void> addFileWithMetadata({
    required int participantId,
    required String title,
    required String type,
    required FileMetadata file,
    DateTime? fileDate,
  }) async {
    await _saveToDb(
      participantId: participantId,
      title: title,
      type: type,
      file: file,
      fileDate: fileDate,
    );
  }

  Future<void> _saveToDb({
    required int participantId,
    required String title,
    required String type,
    required FileMetadata file,
    DateTime? fileDate,
  }) async {
    await db.addFile(
      FilesCompanion.insert(
        participantId: participantId,
        fileId: file.id,
        title: title,
        type: Value(type),
        filePath: file.path,
        source: file.source.name,
        fileSize: Value(file.fileSize),
        fileDate: fileDate ?? file.createdAt,
        mimeType: Value(file.mimeType),
        previewPath: Value(file.previewPath),
        pageCount: Value(file.pageCount),
      ),
    );
  }
}
