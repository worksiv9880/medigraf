import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:medigraf/core/di/providers.dart';
import 'package:medigraf/data/datasources/local/app_database.dart';
import 'package:medigraf/services/db_file_service.dart';
import 'package:medigraf/services/file_service.dart';

import 'package:medigraf/presentation/widgets/app_header/app_header.dart';
import 'package:medigraf/presentation/widgets/participant_filter/participant_filter.dart';

import 'dialogs/upload_file_dialog.dart';
import 'file_preview_page.dart';
import 'widgets/file_card.dart';
import 'widgets/files_header.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage>
    with TickerProviderStateMixin {
  static const List<String> _documentTypes = [
    'LAB_RESULTS',
    'IMAGING',
    'PRESCRIPTIONS',
    'VACCINATIONS',
    'REFERRALS',
    'VISIT_NOTES',
    'ADMINISTRATIVE',
    'RECEIPT',
    'OTHER',
  ];

  // один tag на весь список, чтобы auto-close работал между карточками
  static const Object _slidableGroupTag = 'files_group';

  late final AppDatabase _db;
  late final DbFileService _dbFileService;
  late Future<List<DbFile>> _filesFuture;

  // controller на каждую карточку
  final Map<String, SlidableController> _slidableControllers = {};

  SlidableController _controllerFor(DbFile file) {
    final key = 'file-${file.id}-${file.filePath}';
    return _slidableControllers.putIfAbsent(
      key,
      () => SlidableController(this),
    );
  }

  void _closeAllSlidables() {
    for (final c in _slidableControllers.values) {
      c.close();
    }
  }

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

  @override
  void dispose() {
    for (final c in _slidableControllers.values) {
      c.dispose();
    }
    _slidableControllers.clear();
    super.dispose();
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

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<bool> _editFile(DbFile file) async {
    final controller = TextEditingController(text: file.title);
    String selectedType = _documentTypes.contains(file.type)
        ? file.type
        : (_documentTypes.isNotEmpty ? _documentTypes.first : file.type);
    DateTime selectedDate = file.fileDate;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Edit document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Document title',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: _documentTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(_formatType(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => selectedType = value);
                },
                decoration: const InputDecoration(
                  labelText: 'Document type',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 5),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Document date',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || shouldSave != true) return false;

    final updatedTitle = controller.text.trim();
    if (updatedTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название документа')),
      );
      return false;
    }

    final success = await _dbFileService.updateFileMetadata(
      id: file.id,
      title: updatedTitle,
      type: selectedType,
      fileDate: selectedDate,
    );

    if (!mounted) return false;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось обновить файл')),
      );
      return false;
    }

    setState(_loadFiles);
    return true;
  }

  Future<bool> _deleteFile(DbFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document'),
        content:
            const Text('Удалить этот документ? Это действие нельзя отменить.'),
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

    if (!mounted || confirmed != true) return false;

    await _db.deleteFileById(file.id);

    if (!mounted) return false;

    setState(_loadFiles);
    return true;
  }

  Future<void> _openFilePreview(DbFile file, Participant? participant) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FilePreviewPage(
          file: file,
          participant: participant,
          onShare: _shareFile,
          onEditMetadata: _editFile,
          onDelete: _deleteFile,
        ),
      ),
    );

    if (!mounted || updated != true) return;
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _closeAllSlidables(),
          child: const AppHeader(),
        ),
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ✅ ловим любые нажатия в body (включая ParticipantFilter/FilesHeader/кнопки)
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _closeAllSlidables(),
        child: SafeArea(
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

                    return SlidableAutoCloseBehavior(
                      child: ListView.builder(
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
                          final slidableController = _controllerFor(file);

                          return FileCard(
                            file: file,
                            participant: participantMap[file.participantId],
                            onShare: () => _shareFile(file),
                            onEdit: () async => _editFile(file),
                            onDelete: () async => _deleteFile(file),
                            slidableController: slidableController,
                            slidableGroupTag: _slidableGroupTag,
                            onAnyTapOutside: _closeAllSlidables,
                            onOpen: () => _openFilePreview(
                              file,
                              participantMap[file.participantId],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
