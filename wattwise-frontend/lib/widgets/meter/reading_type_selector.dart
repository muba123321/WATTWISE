import 'package:flutter/material.dart';

class ReadingTypeSelector extends StatelessWidget {
  final List<String> readingTypes;
  final String selectedType;
  final ValueChanged<String> onChanged;

  const ReadingTypeSelector({
    super.key,
    required this.readingTypes,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Type',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? colorScheme.primary.withOpacity(0.2)
                  : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          segments: readingTypes.map((type) {
            return ButtonSegment<String>(
              value: type,
              label: Tooltip(
                message: 'Select ${type.capitalize()} reading',
                child: Text(type.capitalize()),
              ),
              icon: Tooltip(
                message: '${type.capitalize()} icon',
                child: Icon(_getIcon(type)),
              ),
            );
          }).toList(),
          selected: {selectedType},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
      ],
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'electricity':
        return Icons.electric_bolt_outlined;
      case 'gas':
        return Icons.local_fire_department_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'other':
        return Icons.device_unknown;
      default:
        return Icons.dashboard_outlined;
    }
  }
}

extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
