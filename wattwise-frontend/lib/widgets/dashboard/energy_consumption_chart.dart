// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class EnergyConsumptionChart extends StatelessWidget {
//   final List<Map<String, dynamic>> data;
//   final String period;
//   final bool animate;

//   const EnergyConsumptionChart({
//     super.key,
//     required this.data,
//     required this.period,
//     this.animate = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (data.isEmpty) {
//       return Center(
//         child: Text(
//           'No consumption data available',
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       );
//     }

//     return period == 'Hourly' || period == 'Daily'
//         ? _buildBarChart(context)
//         : _buildLineChart(context);
//   }

//   Widget _buildBarChart(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final period = entry.value['period'];
//           final value = (entry.value['value'] as num).toDouble();
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: value,
//                 width: 12,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ],
//           );
//         }).toList(),
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index < 0 || index >= data.length) return Container();
//                 final label = data[index]['period'];
//                 return Text(label, style: const TextStyle(fontSize: 10));
//               },
//               reservedSize: 40,
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 10,
//               getTitlesWidget: (value, _) => Text('${value.toInt()}'),
//               reservedSize: 32,
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: true),
//       ),
//       swapAnimationDuration:
//           animate ? const Duration(milliseconds: 250) : Duration.zero,
//     );
//   }

//   Widget _buildLineChart(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         lineBarsData: [
//           LineChartBarData(
//             spots: data.asMap().entries.map((entry) {
//               final index = entry.key;
//               final value = (entry.value['value'] as num).toDouble();
//               return FlSpot(index.toDouble(), value);
//             }).toList(),
//             isCurved: true,
//             barWidth: 3,
//             color: Theme.of(context).primaryColor,
//             belowBarData: BarAreaData(
//               show: true,
//               color: Theme.of(context).primaryColor.withOpacity(0.3),
//             ),
//             dotData: FlDotData(show: true),
//           ),
//         ],
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index < 0 || index >= data.length) return Container();
//                 final label = data[index]['period'];
//                 return Text(label, style: const TextStyle(fontSize: 10));
//               },
//               reservedSize: 40,
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 10,
//               getTitlesWidget: (value, _) => Text('${value.toInt()}'),
//               reservedSize: 32,
//             ),
//           ),
//         ),
//         borderData: FlBorderData(show: false),
//         gridData: FlGridData(show: true),
//       ),
//       // swapAnimationDuration:
//       //     animate ? const Duration(milliseconds: 250) : Duration.zero,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EnergyConsumptionChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String period;
  final bool animate;

  const EnergyConsumptionChart({
    super.key,
    required this.data,
    required this.period,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No consumption data available',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return period == 'Hourly' || period == 'Daily'
        ? _buildBarChart(context)
        : _buildLineChart(context);
  }

  /// 🔹 BAR CHART
  Widget _buildBarChart(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(context),
        titlesData: _buildTitles(context),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
      duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
      curve: animate ? Curves.easeInOut : Curves.linear,
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = (entry.value['value'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 12,
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  /// 🔹 LINE CHART
  Widget _buildLineChart(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _buildLineSpots(),
            isCurved: true,
            barWidth: 3,
            color: color,
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.3),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: _buildTitles(context),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
      duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
      curve: animate ? Curves.easeInOut : Curves.linear,
    );
  }

  List<FlSpot> _buildLineSpots() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = (entry.value['value'] as num).toDouble();
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  /// 🔹 SHARED TITLES
  FlTitlesData _buildTitles(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            final label = data[index]['period'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(label, style: textStyle?.copyWith(fontSize: 10)),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _getInterval(),
          reservedSize: 32,
          getTitlesWidget: (value, _) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text('${value.toInt()}',
                style: textStyle?.copyWith(fontSize: 10)),
          ),
        ),
      ),
    );
  }

  double _getInterval() {
    final values = data.map((e) => (e['value'] as num).toDouble());
    final max = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b);
    return (max / 4).ceilToDouble();
  }
}
