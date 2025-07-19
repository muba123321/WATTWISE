// import 'package:flutter/material.dart';

// class DashboardSummary extends StatelessWidget {
//   final List<Map<String, dynamic>> devices;

//   const DashboardSummary({super.key, required this.devices});

//   @override
//   Widget build(BuildContext context) {
//     final totalDevices = devices.length;

//     double estimatedCost = 0;
//     for (final d in devices) {
//       final hours = d['usageHoursPerDay'] ?? 0;
//       final watts = d['powerRatingWatts'] ?? 0;
//       final kWhPerMonth = (watts * hours * 30) / 1000;
//       estimatedCost += kWhPerMonth * 0.13; // assume $0.13/kWh
//     }

//     return Card(
//       margin: const EdgeInsets.all(16),
//       color: Colors.green.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _SummaryItem(label: 'Devices', value: '$totalDevices'),
//             _SummaryItem(
//                 label: 'Est. Cost',
//                 value: '\$${estimatedCost.toStringAsFixed(2)}'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SummaryItem extends StatelessWidget {
//   final String label;
//   final String value;

//   const _SummaryItem({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(value,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(color: Colors.grey)),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final int totalDevices;
  final double estimatedMonthlyCost;

  const SummaryCard({
    super.key,
    required this.totalDevices,
    required this.estimatedMonthlyCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryItem(
              label: 'Devices',
              value: '$totalDevices',
              textStyle: theme.textTheme.titleMedium,
              labelStyle: theme.textTheme.bodySmall,
            ),
            _SummaryItem(
              label: 'Est. Cost',
              value: '\$${estimatedMonthlyCost.toStringAsFixed(2)}',
              textStyle: theme.textTheme.titleMedium,
              labelStyle: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.textStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: textStyle),
        const SizedBox(height: 4),
        Text(label, style: labelStyle?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
