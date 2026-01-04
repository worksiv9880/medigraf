import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DaySelector extends StatelessWidget {
  final int days;

  const DaySelector({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: days,
        itemBuilder: (context, index) {
          final day = DateTime.now().subtract(Duration(days: days - 1 - index));
          final isToday = DateUtils.isSameDay(day, DateTime.now());

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              color: isToday ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    color: isToday ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat.MMMd().format(day),
                  style: TextStyle(
                    fontSize: 12,
                    color: isToday ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
