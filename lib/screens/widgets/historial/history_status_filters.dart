import 'package:flutter/material.dart';

class HistoryStatusFilters extends StatelessWidget {
  const HistoryStatusFilters({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
    required this.primaryDark,
    required this.accentIndigo,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color primaryDark;
  final Color accentIndigo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final String filter = filters[index];
          final bool isSelected = selected == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: accentIndigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : primaryDark,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onSelect(filter),
            ),
          );
        },
      ),
    );
  }
}
