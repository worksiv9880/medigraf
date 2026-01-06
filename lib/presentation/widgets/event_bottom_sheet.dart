import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'dart:io';
import '../../core/di/providers.dart';
import '../../data/datasources/local/app_database.dart';
import '../../services/file_service.dart';
import 'file_source_picker.dart';

enum EventSheetContext { calendar, charts, documents }

class EventBottomSheet extends ConsumerStatefulWidget {
  final EventSheetContext context;
  final DateTime? prefilledDate;
  final Metric? prefilledMetric;
  final Participant? prefilledParticipant;

  const EventBottomSheet({
    super.key,
    required this.context,
    this.prefilledDate,
    this.prefilledMetric,
    this.prefilledParticipant,
  });

  @override
  ConsumerState<EventBottomSheet> createState() => _EventBottomSheetState();

  static Future<void> show(
    BuildContext context, {
    required EventSheetContext sheetContext,
    DateTime? prefilledDate,
    Metric? prefilledMetric,
    Participant? prefilledParticipant,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventBottomSheet(
        context: sheetContext,
        prefilledDate: prefilledDate,
        prefilledMetric: prefilledMetric,
        prefilledParticipant: prefilledParticipant,
      ),
    );
  }
}

class _EventBottomSheetState extends ConsumerState<EventBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileService = FileService();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'general';
  String _selectedEmoji = '📅';
  
  final List<Participant> _selectedParticipants = [];
  final List<MetricEntry> _metricEntries = [];
  final List<FileMetadata> _files = [];
  bool _isLoading = false;
  
  final List<String> _categories = [
    'general',
    'appointment',
    'medication',
    'symptom',
    'exercise',
    'diet',
  ];
  
  final Map<String, Color> _categoryColors = {
    'general': Colors.grey,
    'appointment': const Color(0xFFAB47BC),
    'medication': const Color(0xFF4A90E2),
    'symptom': const Color(0xFFEF5350),
    'exercise': const Color(0xFF66BB6A),
    'diet': const Color(0xFFFFA726),
  };
  
  final List<String> _emojis = [
    '📅', '💊', '🏥', '🩺', '💉', '🧬',
    '❤️', '🫀', '🧠', '👁️', '🦷', '🦴',
    '💪', '🏃', '🚶', '🧘', '😴', '😊',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefilledDate != null) {
      _selectedDate = widget.prefilledDate!;
    }
    if (widget.prefilledMetric != null) {
      _metricEntries.add(MetricEntry(
        metric: widget.prefilledMetric!,
        value: '',
        participant: widget.prefilledParticipant,
      ));
    }
    if (widget.prefilledParticipant != null) {
      _selectedParticipants.add(widget.prefilledParticipant!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addMetricEntry() {
    showDialog(
      context: context,
      builder: (dialogContext) => _MetricSelectionDialog(
        onMetricSelected: (metric, participant) {
          setState(() {
            _metricEntries.add(MetricEntry(
              metric: metric,
              value: '',
              participant: participant,
            ));
          });
        },
      ),
    );
  }

  void _addParticipant() {
    final participantsAsync = ref.read(participantsProvider);
    participantsAsync.whenData((participants) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Select Participant'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                final isSelected = _selectedParticipants.contains(participant);
                return CheckboxListTile(
                  title: Text('${participant.emoji} ${participant.name}'),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedParticipants.add(participant);
                      } else {
                        _selectedParticipants.remove(participant);
                      }
                    });
                    Navigator.pop(dialogContext);
                  },
                );
              },
            ),
          ),
        ),
      );
    });
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    final files = await showFileSourcePicker(
      context,
      _fileService,
      allowMultipleFromGallery: true,
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _files.addAll(files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    // Save health event for each participant
    for (final participant in _selectedParticipants) {
      await db.addHealthEvent(
        HealthEventsCompanion(
          participantId: drift.Value(participant.id),
          title: drift.Value(_titleController.text.trim()),
          description: drift.Value(_descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim()),
          eventDate: drift.Value(_selectedDate),
          category: drift.Value(_selectedCategory),
        ),
      );
    }

    // Save metric data points
    for (final entry in _metricEntries) {
      if (entry.value.isNotEmpty) {
        final value = double.tryParse(entry.value);
        if (value != null && entry.participant != null) {
          await db.addDataPoint(
            MetricDataPointsCompanion(
              metricId: drift.Value(entry.metric.id),
              value: drift.Value(value),
              recordedAt: drift.Value(_selectedDate),
            ),
          );
        }
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Create Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  _buildSection(
                    'Date',
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat.yMMMd().format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title
                  _buildSection(
                    'Title',
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Enter event title',
                      ),
                    ),
                  ),

                  // Description
                  _buildSection(
                    'Description',
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter description (optional)',
                      ),
                      maxLines: 3,
                    ),
                  ),

                  // Participants
                  _buildSection(
                    'Participants',
                    Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedParticipants.map((p) => Chip(
                                  label: Text('${p.emoji} ${p.name}'),
                                  onDeleted: () {
                                    setState(() => _selectedParticipants.remove(p));
                                  },
                                )),
                            ActionChip(
                              label: const Text('+ Add'),
                              onPressed: _addParticipant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Metrics
                  _buildSection(
                    'Metrics',
                    Column(
                      children: [
                        ..._metricEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final metricEntry = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${metricEntry.metric.name} (${metricEntry.metric.unit})',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() => _metricEntries.removeAt(index));
                                      },
                                    ),
                                  ],
                                ),
                                if (metricEntry.participant != null)
                                  Text(
                                    'For: ${metricEntry.participant!.emoji} ${metricEntry.participant!.name}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Enter value',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    metricEntry.value = value;
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        OutlinedButton.icon(
                          onPressed: _addMetricEntry,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Metric'),
                        ),
                      ],
                    ),
                  ),

                  // Files
                  _buildSection(
                    'Files',
                    Column(
                      children: [
                        if (_files.isNotEmpty)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _files.length,
                              itemBuilder: (context, index) {
                                final file = _files[index];
                                return _FilePreviewCard(
                                  file: file,
                                  onRemove: () => _removeFile(index),
                                  fileService: _fileService,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          OutlinedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Select file'),
                          ),
                      ],
                    ),
                  ),

                  // Category & Color
                  _buildSection(
                    'Category',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: _categoryColors[category],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = category);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Emoji
                  _buildSection(
                    'Emoji',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _emojis.map((emoji) {
                        final isSelected = emoji == _selectedEmoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = emoji),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveEvent,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Event', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FilePreviewCard extends StatelessWidget {
  const _FilePreviewCard({
    required this.file,
    required this.onRemove,
    required this.fileService,
  });

  final FileMetadata file;
  final VoidCallback onRemove;
  final FileService fileService;

  @override
  Widget build(BuildContext context) {
    final previewPath = file.previewPath;
    final isImageFile = (file.mimeType ?? '').startsWith('image/');
    final hasPreviewFile =
        previewPath != null && previewPath.isNotEmpty && File(previewPath).existsSync();
    final decorationImage = (isImageFile && hasPreviewFile)
        ? DecorationImage(image: FileImage(File(previewPath!)), fit: BoxFit.cover)
        : null;

    IconData sourceIcon;
    switch (file.source) {
      case FileSource.camera:
        sourceIcon = Icons.camera_alt;
        break;
      case FileSource.scanner:
        sourceIcon = Icons.document_scanner;
        break;
      case FileSource.filePicker:
        sourceIcon = Icons.insert_drive_file;
        break;
      case FileSource.gallery:
      default:
        sourceIcon = Icons.photo_library;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        image: decorationImage,
      ),
      child: Stack(
        children: [
          if (decorationImage == null)
            Center(
              child: Icon(
                Icons.insert_drive_file,
                color: Colors.grey.shade700,
                size: 32,
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: onRemove,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sourceIcon,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  if (file.fileSize != null)
                    Text(
                      fileService.formatFileSize(file.fileSize!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  if (file.pageCount != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${file.pageCount}p',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricEntry {
  final Metric metric;
  String value;
  final Participant? participant;

  MetricEntry({
    required this.metric,
    required this.value,
    this.participant,
  });
}

class _MetricSelectionDialog extends ConsumerWidget {
  final Function(Metric metric, Participant? participant) onMetricSelected;

  const _MetricSelectionDialog({required this.onMetricSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider);

    return AlertDialog(
      title: const Text('Add Metric'),
      content: SizedBox(
        width: double.maxFinite,
        child: participantsAsync.when(
          data: (participants) {
            if (participants.isEmpty) {
              return const Text('No participants available');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select participant first:'),
                const SizedBox(height: 16),
                ...participants.map((participant) {
                  final metricsAsync = ref.watch(metricsProvider(participant.id));
                  return ExpansionTile(
                    leading: Text(participant.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(participant.name),
                    children: [
                      metricsAsync.when(
                        data: (metrics) {
                          if (metrics.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No metrics for this participant'),
                            );
                          }
                          return Column(
                            children: metrics.map((metric) {
                              return ListTile(
                                title: Text('${metric.name} (${metric.unit})'),
                                onTap: () {
                                  onMetricSelected(metric, participant);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                    ],
                  );
                }),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
