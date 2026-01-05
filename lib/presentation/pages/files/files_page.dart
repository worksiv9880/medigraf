import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../services/db_file_service.dart';
import '../../../services/file_service.dart';
import 'file_card.dart';
import 'files_header.dart';
import 'upload_file_dialog.dart';
import '../../widgets/app_header/app_header.dart';
import '../../widgets/participant_filter/participant_filter.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
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

  Future<void> _openUploadDialog() async {
    final uploaded = await showDialog<bool>(
      context: context,
      builder: (_) => UploadFileDialog(dbFileService: _dbFileService),
    );

    if (!mounted || uploaded != true) return;

    setState(_loadFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ParticipantFilter(),
            const SizedBox(height: 16),
            FilesHeader(onUpload: _openUploadDialog),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<DbFile>>(
                future: _filesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                      return FileCard(file: files[index]);
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
