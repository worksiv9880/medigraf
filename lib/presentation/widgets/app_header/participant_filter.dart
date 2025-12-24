import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../data/datasources/local/app_database.dart';
import 'participant_button.dart';

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
              final isSelected =
                  selectedParticipant?.id == participant.id;

              return ParticipantButton(
                participant: participant,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(selectedParticipantProvider.notifier)
                      .state = participant;
                },
              );
            }).toList(),
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
