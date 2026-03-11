import 'package:flutter/material.dart';

class IndicatorChipSelector<T> extends StatelessWidget {
  const IndicatorChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(String, T)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        children: options.map(((String, T) entry) {
          final (String label, T value) = entry;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(label),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
