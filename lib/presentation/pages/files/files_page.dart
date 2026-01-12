import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:medigraf/core/di/providers.dart';
import 'package:medigraf/data/datasources/local/app_database.dart';
import 'package:medigraf/services/db_file_service.dart';
import 'package:medigraf/services/file_service.dart';

import 'package:medigraf/presentation/widgets/app_header/app_header.dart';
import 'package:medigraf/presentation/widgets/participant_filter/participant_filter.dart';

import 'dialogs/upload_file_dialog.dart';
import 'widgets/file_card.dart';
import 'widgets/files_header.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  late final AppDatabase _db;
  late final DbFileService _dbFileService;
  late Future<List<DbFile>> _filesFuture;

  List<_FilesListEntry> _buildEntries(
    List<DbFile> files,
    DateFormat monthFormat,
  ) {
    final entries = <_FilesListEntry>[];
    String? currentMonth;

    for (final file in files) {
      final monthKey = monthFormat.format(
        DateTime(file.fileDate.year, file.fileDate.month),
      );
      if (monthKey != currentMonth) {
        currentMonth = monthKey;
        entries.add(_FilesListEntry.header(monthKey));
      }
      entries.add(_FilesListEntry.file(file));
    }

    return entries;
  }

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

  Future<void> _shareFile(DbFile file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.filePath)],
        text: file.title,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось поделиться файлом: $error')),
      );
    }
  }

  Future<void> _renameFile(DbFile file) async {
    final controller = TextEditingController(text: file.title);
    final updatedTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Document title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              controller.text.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted || updatedTitle == null || updatedTitle.isEmpty) {
      return;
    }

    final success = await _dbFileService.renameFile(
      id: file.id,
      title: updatedTitle,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось переименовать файл')),
      );
      return;
    }

    setState(_loadFiles);
  }

  Future<void> _deleteFile(DbFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document'),
        content: const Text('Удалить этот документ? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    await _db.deleteFileById(file.id);

    if (!mounted) return;

    setState(_loadFiles);
  }

  @override
  Widget build(BuildContext context) {
    final selectedParticipants = ref.watch(selectedParticipantsProvider);
    final participantsAsync = ref.watch(participantsProvider);
    final participants = participantsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <Participant>[],
    );
    final participantMap = {
      for (final participant in participants) participant.id: participant
    };
    final monthFormat =
        DateFormat('MMM yyyy', Localizations.localeOf(context).toString());

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
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }

                  final files = snapshot.data ?? [];

                  if (selectedParticipants.isEmpty) {
                    return const Center(
                      child: Text('Выберите участников, чтобы увидеть файлы'),
                    );
                  }

                  final filteredFiles = files
                      .where((file) =>
                          selectedParticipants.contains(file.participantId))
                      .toList();

                  if (filteredFiles.isEmpty) {
                    return const Center(
                      child: Text('Нет файлов для выбранных участников'),
                    );
                  }

                  final entries = _buildEntries(filteredFiles, monthFormat);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      if (entry.header != null) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 12,
                          ),
                          child: Text(
                            entry.header!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }

                      final file = entry.file!;
                      return FileCard(
                        file: file,
                        participant: participantMap[file.participantId],
                        onShare: () => _shareFile(file),
                        onRename: () => _renameFile(file),
                        onDelete: () => _deleteFile(file),
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

class _FilesListEntry {
  final String? header;
  final DbFile? file;

  const _FilesListEntry._({this.header, this.file});

  factory _FilesListEntry.header(String header) =>
      _FilesListEntry._(header: header);

  factory _FilesListEntry.file(DbFile file) => _FilesListEntry._(file: file);
}
