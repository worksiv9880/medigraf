import 'package:flutter/material.dart';

class AllParticipantsButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const AllParticipantsButton({
    super.key,
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
          isSelected ? "❌" : "✅",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
