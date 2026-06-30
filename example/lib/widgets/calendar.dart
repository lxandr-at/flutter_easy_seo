import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

class Calendar extends StatelessWidget {
  final String locale;
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onSelected;
  final bool inline;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const Calendar({
    super.key,
    required this.locale,
    required this.label,
    this.selectedDate,
    this.onSelected,
    this.inline = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFirst = firstDate ?? DateTime.now();
    final effectiveLast = lastDate ?? DateTime(2030);
    final effectiveInitial = selectedDate ?? DateTime.now();

    if (inline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          SizedBox(
            height: 260,
            child: CalendarDatePicker(
              initialDate: effectiveInitial,
              firstDate: effectiveFirst,
              lastDate: effectiveLast,
              onDateChanged: (date) => onSelected?.call(date),
            ),
          ),
        ],
      ).easySeoForm(
        children: [
          if (selectedDate != null)
            SEOTime(text: label, dateTime: selectedDate!),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () => _pickDate(context),
          icon: const Icon(Icons.calendar_month),
          label: Text(selectedDate != null
              ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
              : label),
        ),
      ],
    ).easySeoForm(
      children: [
        if (selectedDate != null)
          SEOTime(text: label, dateTime: selectedDate!),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && onSelected != null) {
      onSelected!(picked);
    }
  }
}
