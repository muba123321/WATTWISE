// import 'package:flutter/material.dart';
// import 'package:wattwise/widgets/dashboard/energy_consumption_chart.dart';

// class EnergySummaryCard extends StatelessWidget {
//   final dynamic period; // Replace `dynamic` with the real model if available
//   final List<Map<String, dynamic>> chartData;
//   final VoidCallback onViewDetails;

//   const EnergySummaryCard({
//     super.key,
//     required this.period,
//     required this.chartData,
//     required this.onViewDetails,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasData = period != null && period.totalConsumption > 0;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Energy Consumption',
//                     style: Theme.of(context).textTheme.headlineSmall),
//                 TextButton(
//                     onPressed: onViewDetails,
//                     child: const Text('View Details')),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Content
//             if (hasData)
//               Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildStat(
//                           context,
//                           'Current',
//                           '${period.totalConsumption.toStringAsFixed(1)} ${period.unit}',
//                           Icons.bolt),
//                       _buildStat(
//                           context,
//                           'Daily Avg',
//                           '${period.averageDaily?.toStringAsFixed(1) ?? 'N/A'} ${period.unit}',
//                           Icons.calendar_today),
//                       if (period.totalCost != null)
//                         _buildStat(
//                             context,
//                             'Cost',
//                             '${period.currency ?? '\$'}${period.totalCost!.toStringAsFixed(2)}',
//                             Icons.attach_money),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     height: 200,
//                     child: EnergyConsumptionChart(
//                         data: chartData, period: 'Monthly'),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStat(
//       BuildContext context, String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: Theme.of(context).primaryColor),
//         ),
//         const SizedBox(height: 8),
//         Text(value,
//             style: Theme.of(context)
//                 .textTheme
//                 .bodySmall
//                 ?.copyWith(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text(label, style: Theme.of(context).textTheme.bodySmall),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:wattwise/widgets/dashboard/energy_consumption_chart.dart';

class EnergySummaryCard extends StatelessWidget {
  final dynamic period; // Replace with `EnergyPeriod` model when available
  final List<Map<String, dynamic>> chartData;
  final VoidCallback onViewDetails;

  const EnergySummaryCard({
    super.key,
    required this.period,
    required this.chartData,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = period != null && period.totalConsumption > 0;
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Energy Consumption',
                    style: theme.textTheme.headlineSmall),
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            if (hasData)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        context: context,
                        label: 'Current',
                        value:
                            '${period.totalConsumption.toStringAsFixed(1)} ${period.unit}',
                        icon: Icons.bolt,
                      ),
                      _buildStat(
                        context: context,
                        label: 'Daily Avg',
                        value:
                            '${period.averageDaily?.toStringAsFixed(1) ?? 'N/A'} ${period.unit}',
                        icon: Icons.calendar_today,
                      ),
                      if (period.totalCost != null)
                        _buildStat(
                          context: context,
                          label: 'Cost',
                          value:
                              '${period.currency ?? '\$'}${period.totalCost!.toStringAsFixed(2)}',
                          icon: Icons.attach_money,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: EnergyConsumptionChart(
                      data: chartData,
                      period: 'Monthly',
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No energy data available yet',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
