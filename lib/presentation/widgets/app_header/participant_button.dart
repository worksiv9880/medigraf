import 'package:flutter/material.dart';
import '../../../data/datasources/local/app_database.dart';

class ParticipantButton extends StatelessWidget {
  final Participant participant;
  final bool isSelected;
  final VoidCallback onTap;

  const ParticipantButton({
    super.key,
    required this.participant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          participant.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}


