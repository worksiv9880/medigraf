import 'package:flutter/material.dart';
import '../../data/datasources/local/app_database.dart';
import '../../services/db_file_service.dart';
import '../../services/file_service.dart';
import 'file_card.dart';
import 'files_header.dart';

class FilesPage extends StatefulWidget {
  final int? participantId;

  const FilesPage({
    super.key,
    required this.participantId,
  });

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late final AppDatabase _db;
  late final DbFileService _dbFileService;

  late Future<List<DbFile>> _filesFuture;

  @override
  void initState() {
    super.initState();

    _db = AppDatabase();
    _dbFileService = DbFileService(_db, FileService());

    _loadFiles();
  }

  void _loadFiles() {
    _filesFuture = _db.getFiles();
  }

  Future<void> _uploadFromGallery() async {
    await _dbFileService.addFromGallery(
      participantId: widget.participantId,
      title: 'New File',
      type: 'GENERAL',
    );
    setState(_loadFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            FilesHeader(
              onUpload: _uploadFromGallery,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<DbFile>>(
                future: _filesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка: ${snapshot.error}'),
                    );
                  }

                  final files = snapshot.data ?? [];

                  if (files.isEmpty) {
                    return const Center(
                      child: Text('Документов пока нет'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return FileCard(
                        file: files[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
