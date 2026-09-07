import 'package:flutter/material.dart';

const _dayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

/// Chip-Reihe zur Auswahl von Wiederholungstagen (1 = Montag ... 7 = Sonntag).
class WeekdaySelector extends StatelessWidget {
  const WeekdaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final selected = selectedDays.contains(weekday);
        return FilterChip(
          label: Text(_dayLabels[index]),
          selected: selected,
          onSelected: (value) {
            final updated = Set<int>.from(selectedDays);
            if (value) {
              updated.add(weekday);
            } else {
              updated.remove(weekday);
            }
            onChanged(updated);
          },
        );
      }),
    );
  }
}
