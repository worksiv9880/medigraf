import 'package:flutter/material.dart';
import '../../data/models/participant.dart';

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
    return IconButton(
      icon: Icon(
        participant.iconData, // или маппинг типа participant.type -> IconData
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: onTap,
    );
  }
}
