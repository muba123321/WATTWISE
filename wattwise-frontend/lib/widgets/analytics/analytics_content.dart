import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/config/app_constants.dart';
import 'package:wattwise/models/appliance_model.dart';
import 'package:wattwise/models/energy_consumption_model.dart';
import 'package:wattwise/providers/analytic_provider.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/providers/energy_provider.dart';
import 'package:wattwise/widgets/dashboard/energy_consumption_chart.dart';

class AnalyticsContent extends StatefulWidget {
  const AnalyticsContent({super.key});

  @override
  State<AnalyticsContent> createState() => _AnalyticsContentState();
}

class _AnalyticsContentState extends State<AnalyticsContent>
    with SingleTickerProviderStateMixin {
  late AnalyticsProvider _analyticsProvider;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsProvider =
          Provider.of<AnalyticsProvider>(context, listen: false);
      _analyticsProvider.tabController = TabController(length: 3, vsync: this);
      _analyticsProvider.initializeData(context);
    });
  }

  @override
  void dispose() {
    _analyticsProvider.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, _) {
        if (analyticsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (analyticsProvider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Analytics',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    analyticsProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => analyticsProvider.initializeData(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            // Energy type selector and period selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Energy type selector
                  Expanded(
                    child: DropdownButtonFormField<ConsumptionType>(
                      decoration: const InputDecoration(
                        labelText: 'Energy Type',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: analyticsProvider.selectedType,
                      items: ConsumptionType.values.map((type) {
                        final String label;
                        switch (type) {
                          case ConsumptionType.electricity:
                            label = 'Electricity';
                            break;
                          case ConsumptionType.gas:
                            label = 'Gas';
                            break;
                          case ConsumptionType.water:
                            label = 'Water';
                            break;
                          case ConsumptionType.other:
                            label = 'Other';
                            break;
                        }
                        return DropdownMenuItem<ConsumptionType>(
                          value: type,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          analyticsProvider.selectedType = value;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Period selector
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Period',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: analyticsProvider.selectedPeriod,
                      items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          analyticsProvider.selectedPeriod = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: analyticsProvider.tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Breakdown'),
                Tab(text: 'Trends'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: analyticsProvider.tabController,
                children: [
                  _buildOverviewTab(context, analyticsProvider),
                  _buildBreakdownTab(context),
                  _buildTrendsTab(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildOverviewTab(
    BuildContext context, AnalyticsProvider analyticsProvider) {
  final energyProvider = Provider.of<EnergyProvider>(context);
  final List<EnergyConsumption> consumptionData =
      energyProvider.filteredConsumptionData(
    type: analyticsProvider.selectedType,
    period: analyticsProvider.selectedPeriod,
  );

  final currentPeriod = energyProvider.currentConsumptionPeriod;

  if (consumptionData.isEmpty) {
    return _buildEmptyDataView('consumption', context);
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        if (currentPeriod != null) _buildSummaryCard(currentPeriod, context),

        const SizedBox(height: 24),

        // Consumption chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy Consumption',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${analyticsProvider.selectedPeriod.toLowerCase()} energy usage',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: EnergyConsumptionChart(
                    data: _getChartData(consumptionData, analyticsProvider),
                    period: analyticsProvider.selectedPeriod,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Comparison with previous periods
        _buildComparisonSection(context),

        const SizedBox(height: 24),

        // Energy-saving tips based on usage patterns
        _buildTipsSection(context),
      ],
    ),
  );
}

Widget _buildBreakdownTab(BuildContext context) {
  final applianceProvider = Provider.of<ApplianceProvider>(context);
  final appliances = applianceProvider.appliances;

  if (appliances.isEmpty) {
    return _buildEmptyDataView('appliances', context);
  }

  // Calculate consumption by appliance
  final Map<String, double> applianceConsumption = {};

  for (final appliance in appliances) {
    applianceConsumption[appliance.name] =
        appliance.calculateMonthlyConsumption();
  }

  // Sort appliances by consumption (descending)
  final sortedAppliances = appliances.toList()
    ..sort((a, b) => b
        .calculateMonthlyConsumption()
        .compareTo(a.calculateMonthlyConsumption()));

  // Calculate total consumption
  final totalConsumption =
      applianceConsumption.values.fold(0.0, (sum, value) => sum + value);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie chart for appliance breakdown
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumption Breakdown',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Energy usage by appliance',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildPieChart(applianceConsumption),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Appliance consumption breakdown list
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appliance Consumption',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monthly usage by appliance',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedAppliances.length,
                  itemBuilder: (context, index) {
                    final appliance = sortedAppliances[index];
                    final consumption = appliance.calculateMonthlyConsumption();
                    final percentage = totalConsumption > 0
                        ? (consumption / totalConsumption * 100)
                        : 0.0;

                    return _buildApplianceConsumptionItem(appliance.name,
                        consumption, percentage, index, context);
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Efficiency recommendations
        _buildEfficiencyRecommendations(sortedAppliances, context),
      ],
    ),
  );
}

Widget _buildTrendsTab(BuildContext context) {
  final energyProvider = Provider.of<EnergyProvider>(context);

  // Get historical consumption periods for comparison
  final periods = energyProvider.consumptionPeriods;

  if (periods.isEmpty) {
    return _buildEmptyDataView('historical data', context);
  }

  // Calculate trends and patterns
  final hasImprovement = _hasConsumptionImprovement(periods);
  final averageConsumption = _calculateAverageConsumption(periods);
  final peakConsumptionHour =
      _getPeakConsumptionHour(energyProvider.hourlyConsumptionData);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usage trends chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumption Trends',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Historical energy usage over time',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _buildTrendsChart(periods),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Usage patterns
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usage Patterns',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Average consumption
                _buildPatternItem(
                    'Average Daily Consumption',
                    '${averageConsumption.toStringAsFixed(1)} kWh',
                    Icons.timeline,
                    context),

                // Peak consumption hour
                if (peakConsumptionHour != null)
                  _buildPatternItem(
                      'Peak Usage Time',
                      _formatHour(peakConsumptionHour),
                      Icons.access_time,
                      context),

                // Improvement indicator
                _buildPatternItem(
                    'Usage Trend',
                    hasImprovement ? 'Decreasing' : 'Increasing',
                    hasImprovement ? Icons.trending_down : Icons.trending_up,
                    color: hasImprovement ? Colors.green : Colors.red,
                    context),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Seasonal analysis
        _buildSeasonalAnalysis(periods, context),
      ],
    ),
  );
}

Widget _buildSummaryCard(ConsumptionPeriod period, BuildContext context) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Period Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                  'Total',
                  '${period.totalConsumption.toStringAsFixed(1)} ${period.unit}',
                  Icons.bolt,
                  context),
              _buildSummaryItem(
                  'Daily Avg',
                  '${period.averageDaily?.toStringAsFixed(1) ?? 'N/A'} ${period.unit}',
                  Icons.today,
                  context),
              if (period.totalCost != null)
                _buildSummaryItem(
                    'Cost',
                    '${period.currency ?? '\$'}${period.totalCost!.toStringAsFixed(2)}',
                    Icons.attach_money,
                    context),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('MMM d').format(period.startDate)} - ${DateFormat('MMM d, yyyy').format(period.endDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildSummaryItem(
    String label, String value, IconData icon, BuildContext context) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
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

Widget _buildComparisonSection(BuildContext context) {
  // This would ideally come from the energy provider
  // For now, we'll use sample comparison data
  const double currentUsage = 320.5;
  const double previousUsage = 350.2;
  const double difference = previousUsage - currentUsage;
  const double percentageChange = (difference / previousUsage) * 100;

  final isImprovement = difference > 0;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Current',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentUsage.toStringAsFixed(1)} kWh',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                isImprovement ? Icons.arrow_downward : Icons.arrow_upward,
                color: isImprovement ? Colors.green : Colors.red,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Previous',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${previousUsage.toStringAsFixed(1)} kWh',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isImprovement
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isImprovement ? Icons.thumb_up : Icons.thumb_down,
                  color: isImprovement ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isImprovement
                        ? 'You used ${difference.abs().toStringAsFixed(1)} kWh (${percentageChange.abs().toStringAsFixed(1)}%) less energy compared to the previous period!'
                        : 'You used ${difference.abs().toStringAsFixed(1)} kWh (${percentageChange.abs().toStringAsFixed(1)}%) more energy compared to the previous period.',
                    style: TextStyle(
                      color: isImprovement ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTipsSection(BuildContext context) {
  // Get random tips from the constants
  final tips = List<String>.from(AppConstants.energySavingTips)..shuffle();
  final selectedTips = tips.take(3).toList();

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Energy Saving Tips',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...selectedTips.map((tip) => _buildTipItem(tip, context)),
        ],
      ),
    ),
  );
}

Widget _buildTipItem(String tip, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(tip),
        ),
      ],
    ),
  );
}

Widget _buildPieChart(Map<String, double> applianceConsumption) {
  if (applianceConsumption.isEmpty) {
    return const Center(child: Text('No consumption data available'));
  }

  final total =
      applianceConsumption.values.fold(0.0, (sum, value) => sum + value);
  final entries = applianceConsumption.entries.toList();

  return PieChart(
    PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: List.generate(entries.length, (index) {
        final key = entries[index].key;
        final value = entries[index].value;
        final percentage = (value / total * 100).toStringAsFixed(1);
        final color = Colors.primaries[index % Colors.primaries.length];

        return PieChartSectionData(
          color: color,
          value: value,
          title: '$percentage%',
          titleStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          radius: 60,
        );
      }),
    ),
  );
}

Widget _buildApplianceConsumptionItem(String name, double consumption,
    double percentage, int index, BuildContext context) {
  final color = Colors.primaries[index % Colors.primaries.length];

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${consumption.toStringAsFixed(1)} kWh',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEfficiencyRecommendations(
    List<dynamic> sortedAppliances, BuildContext context) {
  if (sortedAppliances.isEmpty) {
    return const SizedBox.shrink();
  }

  // Get the top energy consuming appliances
  final topConsumers = sortedAppliances.take(3).toList();

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efficiency Recommendations',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...topConsumers.map((appliance) {
            return _buildRecommendationItem(appliance.name,
                _getRecommendationForAppliance(appliance), context);
          }),
        ],
      ),
    ),
  );
}

String _getRecommendationForAppliance(dynamic appliance) {
  if (appliance.efficiency == ApplianceEfficiency.low) {
    return 'Consider replacing this appliance with a more energy-efficient model.';
  } else if (appliance.dailyUsageHours > 8) {
    return 'Try to reduce the daily usage of this appliance to save energy.';
  } else if (appliance.standbyPower != null && appliance.standbyPower > 5) {
    return 'Unplug this appliance when not in use to reduce standby consumption.';
  } else {
    return 'Use during off-peak hours to reduce energy costs.';
  }
}

Widget _buildRecommendationItem(
    String appliance, String recommendation, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_outline,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appliance,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(recommendation),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTrendsChart(List<ConsumptionPeriod> periods) {
  final sorted = List<ConsumptionPeriod>.from(periods)
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  final List<FlSpot> spots = [];
  final List<String> labels = [];

  for (int i = 0; i < sorted.length; i++) {
    spots.add(FlSpot(i.toDouble(), sorted[i].totalConsumption));
    labels.add(DateFormat('MMM').format(sorted[i].startDate));
  }

  return LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: Colors.blue,
          belowBarData:
              BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
        )
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= labels.length) return Container();
              return Text(labels[index], style: const TextStyle(fontSize: 10));
            },
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) => Text('${value.toInt()}'),
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
    ),
  );
}

Widget _buildPatternItem(
    String label, String value, IconData icon, BuildContext context,
    {Color? color}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSeasonalAnalysis(
    List<ConsumptionPeriod> periods, BuildContext context) {
  // This would be based on historical data
  // For now, we'll use sample seasonal data
  final Map<String, double> seasonalData = {
    'Winter': 450.0,
    'Spring': 320.0,
    'Summer': 380.0,
    'Fall': 340.0,
  };

  // Find the season with highest consumption
  final highestSeason =
      seasonalData.entries.reduce((a, b) => a.value > b.value ? a : b);

  // Find the season with lowest consumption
  final lowestSeason =
      seasonalData.entries.reduce((a, b) => a.value < b.value ? a : b);

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Analysis',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildSeasonalChart(seasonalData),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your energy usage is highest in ${highestSeason.key} (${highestSeason.value.toStringAsFixed(1)} kWh) and lowest in ${lowestSeason.key} (${lowestSeason.value.toStringAsFixed(1)} kWh).',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSeasonalChart(Map<String, double> seasonalData) {
  final items = seasonalData.entries.toList();
  return BarChart(
    BarChartData(
      barGroups: List.generate(items.length, (index) {
        final value = items[index].value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              width: 18,
              color: Colors.primaries[index % Colors.primaries.length],
            ),
          ],
        );
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= items.length) return Container();
              return Text(items[index].key,
                  style: const TextStyle(fontSize: 10));
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 100,
            getTitlesWidget: (value, _) => Text('${value.toInt()}'),
            reservedSize: 32,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true),
    ),
  );
}

Widget _buildEmptyDataView(String dataType, BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.analytics,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No $dataType data available',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Add meter readings and appliances to see analytics and insights.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

List<Map<String, dynamic>> _getChartData(
    List<EnergyConsumption> consumptionData,
    AnalyticsProvider analyticsProvider) {
  final Map<String, double> aggregatedData = {};

  for (final consumption in consumptionData) {
    final String key;

    switch (analyticsProvider.selectedPeriod) {
      case 'Daily':
        key = DateFormat('MMM d').format(consumption.date);
        break;
      case 'Weekly':
        // Get the week number
        final weekNumber = (consumption.date.day / 7).ceil();
        key = 'Week $weekNumber';
        break;
      case 'Monthly':
        key = DateFormat('MMM yyyy').format(consumption.date);
        break;
      case 'Yearly':
        key = DateFormat('yyyy').format(consumption.date);
        break;
      default:
        key = DateFormat('MMM d').format(consumption.date);
        break;
    }

    if (aggregatedData.containsKey(key)) {
      aggregatedData[key] = aggregatedData[key]! + consumption.amount;
    } else {
      aggregatedData[key] = consumption.amount;
    }
  }

  return aggregatedData.entries.map((entry) {
    return {
      'period': entry.key,
      'value': entry.value,
    };
  }).toList();
}

bool _hasConsumptionImprovement(List<ConsumptionPeriod> periods) {
  if (periods.length < 2) return false;

  // Sort periods by end date, most recent first
  final sortedPeriods = List<ConsumptionPeriod>.from(periods)
    ..sort((a, b) => b.endDate.compareTo(a.endDate));

  // Compare the two most recent periods
  return sortedPeriods[0].totalConsumption < sortedPeriods[1].totalConsumption;
}

double _calculateAverageConsumption(List<ConsumptionPeriod> periods) {
  if (periods.isEmpty) return 0.0;

  double totalDailyConsumption = 0.0;
  int totalDays = 0;

  for (final period in periods) {
    if (period.averageDaily != null) {
      totalDailyConsumption += period.averageDaily! * period.durationDays;
      totalDays += period.durationDays;
    }
  }

  return totalDays > 0 ? totalDailyConsumption / totalDays : 0.0;
}

int? _getPeakConsumptionHour(List<Map<String, dynamic>> hourlyData) {
  if (hourlyData.isEmpty) return null;

  // Find the hour with highest consumption
  int peakHour = 0;
  double maxConsumption = 0.0;

  for (final data in hourlyData) {
    final hour = data['hour'] as int;
    final consumption = data['value'] as double;

    if (consumption > maxConsumption) {
      maxConsumption = consumption;
      peakHour = hour;
    }
  }

  return peakHour;
}

String _formatHour(int hour) {
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:00 $period';
}

class ApplianceConsumptionData {
  final String appliance;
  final double consumption;
  final Color color;

  ApplianceConsumptionData(this.appliance, this.consumption, this.color);
}
