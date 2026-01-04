import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';
import 'participant_button.dart';
import 'all_participants_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../data/datasources/local/app_database.dart';
import 'participant_button.dart';

class ParticipantFilter extends ConsumerWidget {
  const ParticipantFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(participantsProvider);
    final selectedParticipants = ref.watch(selectedParticipantsProvider);

    ref.listen(participantsProvider, (prev, next) {
      next.whenData((participants) {
        if (participants.isEmpty) return;

        final notifier = ref.read(selectedParticipantsProvider.notifier);

        if (notifier.state.isEmpty) {
          final allIds = participants.map((p) => p.id).toSet();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifier.state = allIds;
          });
        }
      });
    });

    return participantsAsync.when(
      data: (participants) {
        if (participants.isEmpty) {
          return const SizedBox.shrink();
        }
        final allIds = participants.map((p) => p.id).toSet();
        final isAllSelected =
            selectedParticipants.length == allIds.length && allIds.isNotEmpty;

        return ColoredBox(
          color: Theme.of(context).cardColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AllParticipantsButton(
                      isSelected: isAllSelected,
                      onTap: () {
                        final notifier =
                            ref.read(selectedParticipantsProvider.notifier);
                        notifier.state = isAllSelected ? {} : allIds;
                      },
                    ),
                    ...participants.map((participant) {
                      final isSelected =
                          selectedParticipants.contains(participant.id);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ParticipantButton(
                          participant: participant,
                          isSelected: isSelected,
                          onTap: () {
                            final notifier =
                                ref.read(selectedParticipantsProvider.notifier);

                            if (isSelected) {
                              notifier.state = {...notifier.state}
                                ..remove(participant.id);
                            } else {
                              notifier.state = {
                                ...notifier.state,
                                participant.id,
                              };
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
