import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wattwise/providers/meter_reading_provider.dart';
import 'package:wattwise/widgets/appliance/meter_reading_card.dart';
import 'package:wattwise/widgets/meter/meter_reading_input.dart';

class MeterReadingScreen extends StatelessWidget {
  const MeterReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeterReadingProvider()..fetchReadings(),
      child: Consumer<MeterReadingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Failed to load readings'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(provider.errorMessage,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchReadings,
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (provider.isAdding) {
            return MeterReadingInput(
              onSubmit: (val, time, type, source, {notes, billingCycle}) =>
                  provider.addReading(val, time, type, source,
                      notes: notes, billingCycle: billingCycle),
              onCancel: provider.toggleAddReading,
            );
          }

          final readings = provider.readings;

          return Scaffold(
            body: readings.isEmpty
                ? _buildEmptyState(context, provider)
                : RefreshIndicator(
                    onRefresh: provider.fetchReadings,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: readings.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meter Readings',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track your energy usage over time.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }

                        return MeterReadingCard(
                            reading: readings[index - 1],
                            onDelete: provider.deleteReading);
                      },
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: provider.toggleAddReading,
              tooltip: 'Add Meter Reading',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MeterReadingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/empty_reading.svg', height: 120),
            const SizedBox(height: 24),
            Text('No Meter Readings Yet',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Add your first meter reading to start tracking energy usage.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.toggleAddReading,
              icon: const Icon(Icons.add),
              label: const Text('Add First Reading'),
            )
          ],
        ),
      ),
    );
  }
}
