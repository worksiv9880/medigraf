import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  Set<String> _selectedTypes = {};
  _DateFilter _dateFilter = _DateFilter.any;
  DateTime? _customFromDate;
  DateTime? _customToDate;
  _SortOption _sortOption = _SortOption.newest;

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
    _selectedTypes = {..._documentTypes};

    _loadFiles();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    for (final c in _slidableControllers.values) {
      c.dispose();
    }
    _slidableControllers.clear();
    super.dispose();
  }

  void _loadFiles() {
    _filesFuture = _db.getFiles();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim());
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() => _searchQuery = '');
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

  int get _activeFilterCount {
    var count = 0;
    if (_selectedTypes.length != _documentTypes.length) {
      count++;
    }
    if (_dateFilter != _DateFilter.any) {
      count++;
    }
    if (_sortOption != _SortOption.newest) {
      count++;
    }
    return count;
  }

  bool get _hasActiveFilters => _activeFilterCount > 0;

  bool _matchesTypeFilter(DbFile file) {
    return _selectedTypes.contains(file.type);
  }

  bool _matchesDateFilter(DbFile file) {
    if (_dateFilter == _DateFilter.any) {
      return true;
    }

    final now = DateTime.now();
    final fileDate = file.fileDate;

    switch (_dateFilter) {
      case _DateFilter.last7Days:
        return fileDate.isAfter(now.subtract(const Duration(days: 7)));
      case _DateFilter.last30Days:
        return fileDate.isAfter(now.subtract(const Duration(days: 30)));
      case _DateFilter.thisYear:
        return fileDate.year == now.year;
      case _DateFilter.custom:
        if (_customFromDate != null) {
          final start = DateTime(
            _customFromDate!.year,
            _customFromDate!.month,
            _customFromDate!.day,
          );
          if (fileDate.isBefore(start)) {
            return false;
          }
        }
        if (_customToDate != null) {
          final end = DateTime(
            _customToDate!.year,
            _customToDate!.month,
            _customToDate!.day,
            23,
            59,
            59,
          );
          if (fileDate.isAfter(end)) {
            return false;
          }
        }
        return true;
      case _DateFilter.any:
        return true;
    }
  }

  double? _searchScore(DbFile file, String query, DateFormat monthFormat) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    final terms = trimmed.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final title = file.title.toLowerCase();
    final type = _formatType(file.type).toLowerCase();
    final dateText = [
      _formatDate(file.fileDate),
      DateFormat('dd.MM').format(file.fileDate),
      DateFormat('yyyy').format(file.fileDate),
      monthFormat.format(file.fileDate),
      file.fileDate.month.toString().padLeft(2, '0'),
    ].join(' ').toLowerCase();

    var score = 0.0;
    for (final term in terms) {
      var termScore = 0.0;
      if (title.startsWith(term)) {
        termScore = 4.0;
      } else if (title.contains(term)) {
        termScore = 3.0;
      } else if (type.startsWith(term)) {
        termScore = 2.0;
      } else if (type.contains(term)) {
        termScore = 1.0;
      } else if (dateText.contains(term)) {
        termScore = 0.5;
      }
      if (termScore == 0.0) {
        return null;
      }
      score += termScore;
    }
    return score;
  }

  int _compareBySortOption(DbFile a, DbFile b) {
    switch (_sortOption) {
      case _SortOption.newest:
        return b.fileDate.compareTo(a.fileDate);
      case _SortOption.oldest:
        return a.fileDate.compareTo(b.fileDate);
      case _SortOption.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  Future<void> _openFiltersSheet() async {
    final theme = Theme.of(context);
    final tempSelectedTypes = {..._selectedTypes};
    var tempDateFilter = _dateFilter;
    var tempFromDate = _customFromDate;
    var tempToDate = _customToDate;
    var tempSortOption = _sortOption;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickDate({
            required bool isFrom,
            required DateTime initialDate,
          }) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(DateTime.now().year - 10),
              lastDate: DateTime(DateTime.now().year + 10),
            );
            if (picked == null) return;
            setModalState(() {
              if (isFrom) {
                tempFromDate = picked;
              } else {
                tempToDate = picked;
              }
            });
          }

          void resetFilters() {
            setModalState(() {
              tempSelectedTypes
                ..clear()
                ..addAll(_documentTypes);
              tempDateFilter = _DateFilter.any;
              tempFromDate = null;
              tempToDate = null;
              tempSortOption = _SortOption.newest;
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const topPadding = 48.0;
                return SafeArea(
                  top: true,
                  bottom: false,
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            topPadding,
                            24,
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Filters',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close),
                                    tooltip: 'Close',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Document type',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ..._documentTypes.map(
                                (type) => CheckboxListTile(
                                  value: tempSelectedTypes.contains(type),
                                  onChanged: (value) {
                                    setModalState(() {
                                      if (value == true) {
                                        tempSelectedTypes.add(type);
                                      } else {
                                        tempSelectedTypes.remove(type);
                                      }
                                    });
                                  },
                                  title: Text(_formatType(type)),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Date range',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ..._DateFilter.values.map(
                                (filter) => RadioListTile<_DateFilter>(
                                  value: filter,
                                  groupValue: tempDateFilter,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setModalState(() => tempDateFilter = value);
                                  },
                                  title: Text(_dateFilterLabel(filter)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              if (tempDateFilter == _DateFilter.custom) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => pickDate(
                                          isFrom: true,
                                          initialDate:
                                              tempFromDate ?? DateTime.now(),
                                        ),
                                        child: Text(
                                          tempFromDate == null
                                              ? 'From'
                                              : _formatDate(tempFromDate!),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => pickDate(
                                          isFrom: false,
                                          initialDate:
                                              tempToDate ?? DateTime.now(),
                                        ),
                                        child: Text(
                                          tempToDate == null
                                              ? 'To'
                                              : _formatDate(tempToDate!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Text(
                                'Sort',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ..._SortOption.values.map(
                                (option) => RadioListTile<_SortOption>(
                                  value: option,
                                  groupValue: tempSortOption,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setModalState(() => tempSortOption = value);
                                  },
                                  title: Text(_sortOptionLabel(option)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: resetFilters,
                                  child: const Text('Reset'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedTypes = tempSelectedTypes;
                                      _dateFilter = tempDateFilter;
                                      _customFromDate = tempFromDate;
                                      _customToDate = tempToDate;
                                      _sortOption = tempSortOption;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _dateFilterLabel(_DateFilter filter) {
    switch (filter) {
      case _DateFilter.any:
        return 'Any time';
      case _DateFilter.last7Days:
        return 'Last 7 days';
      case _DateFilter.last30Days:
        return 'Last 30 days';
      case _DateFilter.thisYear:
        return 'This year';
      case _DateFilter.custom:
        return 'Custom';
    }
  }

  String _sortOptionLabel(_SortOption option) {
    switch (option) {
      case _SortOption.newest:
        return 'Newest first';
      case _SortOption.oldest:
        return 'Oldest first';
      case _SortOption.title:
        return 'Title A–Z';
    }
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
              FilesHeader(
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
                onOpenFilters: _openFiltersSheet,
                activeFilterCount: _activeFilterCount,
              ),
              const SizedBox(height: 8),
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

                    final participantFiltered = files
                        .where((file) =>
                            selectedParticipants.contains(file.participantId))
                        .toList();

                    if (participantFiltered.isEmpty) {
                      return const Center(
                        child: Text('Нет файлов для выбранных участников'),
                      );
                    }

                    final typeFiltered = participantFiltered
                        .where(_matchesTypeFilter)
                        .where(_matchesDateFilter)
                        .toList();

                    final hasSearchQuery = _searchQuery.isNotEmpty;
                    final visibleFiles = <DbFile>[];

                    if (hasSearchQuery) {
                      final scored = <_ScoredFile>[];
                      for (final file in typeFiltered) {
                        final score =
                            _searchScore(file, _searchQuery, monthFormat);
                        if (score != null) {
                          scored.add(_ScoredFile(file, score));
                        }
                      }
                      scored.sort((a, b) {
                        final scoreCompare =
                            b.score.compareTo(a.score);
                        if (scoreCompare != 0) {
                          return scoreCompare;
                        }
                        return _compareBySortOption(a.file, b.file);
                      });
                      visibleFiles.addAll(scored.map((item) => item.file));
                    } else {
                      visibleFiles.addAll(typeFiltered);
                      visibleFiles.sort(_compareBySortOption);
                    }

                    if (visibleFiles.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasSearchQuery || _hasActiveFilters)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${visibleFiles.length} results',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          const Spacer(),
                          const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No results',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try different keywords or clear filters',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      );
                    }

                    final entries = _buildEntries(visibleFiles, monthFormat);

                    return SlidableAutoCloseBehavior(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasSearchQuery || _hasActiveFilters)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${visibleFiles.length} results',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                final slidableController =
                                    _controllerFor(file);

                                return FileCard(
                                  file: file,
                                  participant:
                                      participantMap[file.participantId],
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openUploadDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

enum _DateFilter {
  any,
  last7Days,
  last30Days,
  thisYear,
  custom,
}

enum _SortOption {
  newest,
  oldest,
  title,
}

class _FilesListEntry {
  final String? header;
  final DbFile? file;

  const _FilesListEntry._({this.header, this.file});

  factory _FilesListEntry.header(String header) =>
      _FilesListEntry._(header: header);

  factory _FilesListEntry.file(DbFile file) => _FilesListEntry._(file: file);
}

class _ScoredFile {
  final DbFile file;
  final double score;

  const _ScoredFile(this.file, this.score);
}
