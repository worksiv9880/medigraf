import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';

class ParticipantFilter extends ConsumerWidget {
  const ParticipantFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider);
    final selectedParticipant = ref.watch(selectedParticipantProvider);

    return participantsAsync.when(
      data: (participants) {
        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: participants.map((participant) {
              final isSelected = selectedParticipant?.id == participant.id;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedParticipantProvider.notifier).state =
                      participant;
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    participant.emoji, // используем emoji вместо iconData
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
