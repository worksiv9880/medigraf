import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../widgets/app_header/app_header.dart';
import '../../widgets/participant_filter/participant_filter.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<String, Color> categoryColors = {
    'appointment': const Color(0xFFAB47BC),
    'medication': const Color(0xFF4A90E2),
    'symptom': const Color(0xFFEF5350),
    'exercise': const Color(0xFF66BB6A),
    'diet': const Color(0xFFFFA726),
    'general': Colors.grey,
    'file': const Color(0xFF607D8B),
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _showAddEventDialog() {
    final selectedParticipants = ref.read(selectedParticipantsProvider);
    if (selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a participant first')),
      );
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'general';
    final categories = [
      'general',
      'appointment',
      'medication',
      'symptom',
      'exercise',
      'diet'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => AlertDialog(
          title: const Text('Add Health Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => category = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final db = ref.read(databaseProvider);
                await db.addHealthEvent(
                  HealthEventsCompanion(
                    participantId: drift.Value(selectedParticipants.first),
                    title: drift.Value(titleController.text.trim()),
                    description: drift.Value(descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim()),
                    eventDate: drift.Value(_selectedDay ?? _focusedDay),
                    category: drift.Value(category),
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  List<_CalendarItem> _buildCalendarItems(
    List<HealthEvent> events,
    List<DbFile> files,
  ) {
    final eventItems = events
        .map((event) => _CalendarItem(
              date: event.eventDate,
              title: event.title,
              description: event.description,
              category: event.category,
              type: _CalendarItemType.event,
            ))
        .toList();

    final fileItems = files
        .map((file) => _CalendarItem(
              date: file.fileDate,
              title: file.title,
              description: file.type,
              category: 'file',
              type: _CalendarItemType.file,
            ))
        .toList();

    return [...eventItems, ...fileItems];
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(participantsProvider);
    final selectedParticipants = ref.watch(selectedParticipantsProvider);
    final eventsAsync = selectedParticipants.isNotEmpty
        ? ref.watch(healthEventsProvider(selectedParticipants.first))
        : const AsyncValue.data(<HealthEvent>[]);
    final filesAsync = selectedParticipants.isNotEmpty
        ? ref.watch(filesProvider(selectedParticipants.first))
        : const AsyncValue.data(<DbFile>[]);

    final combinedItems = _buildCalendarItems(
      eventsAsync.value ?? const [],
      filesAsync.value ?? const [],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AppHeader(),
      body: Column(
        children: [
          ParticipantFilter(),

          // Calendar
          Container(
            color: Theme.of(context).cardColor,
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                selectedDecoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                outsideDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5),
                ),
                todayTextStyle: const TextStyle(color: Colors.red),
                selectedTextStyle: const TextStyle(color: Colors.black),
                cellMargin: const EdgeInsets.all(4),
              ),
              eventLoader: (day) {
                return combinedItems
                    .where((entry) => isSameDay(entry.date, day))
                    .toList();
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, day, focusedDay) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(4),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSameDay(day, DateTime.now())
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  );
                },
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final calendarEntries = events.cast<_CalendarItem>();
                  return Positioned(
                    bottom: 2,
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: categoryColors[calendarEntries.first.category] ??
                            Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Events List
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (eventsAsync.isLoading || filesAsync.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filesAsync.hasError) {
                  return Center(child: Text('Error: ${filesAsync.error}'));
                }

                final selectedEntries = combinedItems.where((item) {
                  return isSameDay(item.date, _selectedDay ?? _focusedDay);
                }).toList()
                  ..sort((a, b) => a.type.index.compareTo(b.type.index));

                if (selectedEntries.isEmpty) {
                  return Center(
                    child: Text(
                      'No events for ${DateFormat('MMM d').format(_selectedDay ?? _focusedDay)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Items for ${DateFormat('MMM d').format(_selectedDay ?? _focusedDay)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...selectedEntries.map((entry) => _buildEntryCard(entry)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEntryCard(_CalendarItem item) {
    final color = categoryColors[item.category] ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.type == _CalendarItemType.event
                  ? Icons.calendar_today
                  : Icons.insert_drive_file,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _CalendarItemType { event, file }

class _CalendarItem {
  final DateTime date;
  final String title;
  final String? description;
  final String category;
  final _CalendarItemType type;

  _CalendarItem({
    required this.date,
    required this.title,
    this.description,
    required this.category,
    required this.type,
  });
}
