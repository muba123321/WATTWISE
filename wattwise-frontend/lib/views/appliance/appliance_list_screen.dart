import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/widgets/appliance/appliance_card.dart';
import 'package:wattwise/widgets/common/empty_appliances_state.dart';

class ApplianceListScreen extends StatelessWidget {
  const ApplianceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Appliances'),
      ),
      body: Consumer<ApplianceProvider>(
        builder: (context, provider, _) {
          final appliances = provider.appliances;
          final isLoading = provider.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appliances.isEmpty) {
            return EmptyAppliancesState(
              onAddAppliance: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appliances.length,
            itemBuilder: (context, index) => ApplianceCard(
              appliance: appliances[index],
              onTap: () {
                // TODO: Navigate to appliance details
              },
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }
}
