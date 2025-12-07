import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/di/providers.dart';
import '../../data/datasources/local/app_database.dart';

class ParticipantsPage extends ConsumerStatefulWidget {
  const ParticipantsPage({super.key});

  @override
  ConsumerState<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends ConsumerState<ParticipantsPage> {
  final List<String> emojis = ['👤', '👨', '👩', '👶', '🐕', '🐈', '🐦', '🐰', '🐹', '🐢'];

  void _showAddDialog() {
    final nameController = TextEditingController();
    String selectedEmoji = emojis[0];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, dialogSetState) => AlertDialog(
          title: const Text('Add Participant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Emoji:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: emojis.map((emoji) {
                  final isSelected = emoji == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => selectedEmoji = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected 
                          ? Theme.of(builderContext).colorScheme.primary 
                          : Colors.transparent,
                         width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        shape: BoxShape.rectangle,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
               if (name.isEmpty) {
                 ScaffoldMessenger.maybeOf(dialogContext)
                 ?.showSnackBar(const SnackBar(content: Text('Please enter a name')));
                    return;
               }

               await ref.read(databaseProvider).addParticipant(
                    ParticipantsCompanion(
                        name: drift.Value(name),
                       emoji: drift.Value(selectedEmoji),
                  ),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Participant added successfully')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(participantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: participantsAsync.when(
        data: (participants) {
          if (participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No participants yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first participant',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return ListTile(
                leading: Text(participant.emoji, style: const TextStyle(fontSize: 32)),
                title: Text(participant.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Participant'),
      content: Text('Are you sure you want to delete ${participant.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

  await ref.read(databaseProvider).deleteParticipant(participant.id);

  if (!mounted) return;                                // ← эта строка должна быть сразу перед ScaffoldMessenger

  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Participant deleted')),
  );
},
                  
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}