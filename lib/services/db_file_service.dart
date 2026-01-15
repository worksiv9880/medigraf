import 'dart:io';

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
    if (file == null) {
      throw Exception('Не удалось сохранить файл (camera)');
    }

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
    if (file == null || participantId == null) {
      throw Exception('Не удалось сохранить файл (gallery)');
    }

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
    if (files.isEmpty) {
      throw Exception('Не удалось сохранить файл (scanner)');
    }

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

  /// ✅ Гарантирует: если запись добавлена в БД, файл реально существует.
  Future<void> addFileWithMetadata({
    required int participantId,
    required String title,
    required String type,
    required FileMetadata file,
    DateTime? fileDate,
  }) async {
    // 1) Проверяем существование физического файла
    final exists = await File(file.path).exists();
    final size = exists ? await File(file.path).length() : 0;

    if (!exists || size == 0) {
      throw Exception('Файл не сохранён на диске: ${file.path}');
    }

    // 2) Сохраняем в БД
    await _saveToDb(
      participantId: participantId,
      title: title,
      type: type,
      file: file.copyWith(fileSize: size),
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
      ),
    );
  }

  Future<bool> renameFile({
    required int id,
    required String title,
  }) async {
    final updated = await db.updateFileTitle(id, title);
    return updated > 0;
  }

  Future<bool> updateFileMetadata({
    required int id,
    required String title,
    required String type,
    required DateTime fileDate,
  }) async {
    final updated = await db.updateFileMetadata(
      id,
      title: title,
      type: type,
      fileDate: fileDate,
    );
    return updated > 0;
  }
}

extension on FileMetadata {
  FileMetadata copyWith({int? fileSize}) {
    return FileMetadata(
      id: id,
      path: path,
      fileName: fileName,
      source: source,
      createdAt: createdAt,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
