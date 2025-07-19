import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/providers/energy_provider.dart';
import 'package:wattwise/providers/home_provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/widgets/home/greeting_header.dart';
import 'package:wattwise/widgets/home/energy_summary_card.dart';
import 'package:wattwise/widgets/home/qick_actions_grid.dart';
import 'package:wattwise/widgets/home/recent_appliances_list.dart';
import 'package:wattwise/widgets/common/empty_appliances_state.dart';
import 'package:wattwise/widgets/common/empty_consumption_state.dart';
import 'package:wattwise/widgets/dashboard/energy_tips_card.dart';
import 'package:wattwise/config/app_constants.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.read<HomeProvider>();
    final energyProvider = context.read<EnergyProvider>();
    final applianceProvider = context.read<ApplianceProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final currentPeriod = energyProvider.currentConsumptionPeriod;
    final appliances = applianceProvider.appliances;
    final hasAppliances = appliances.isNotEmpty;
    final hasConsumption =
        currentPeriod != null && currentPeriod.totalConsumption > 0;

    if (user == null) {
      return const Center(child: Text('User data not available'));
    }

    log('first name: ${user.firstName}');
    log('last name: ${user.lastName}');
    log('email name: ${user.email}');
    log('photoUrl name: ${user..photoUrl}');
    log('isEmailVerified: ${user.isEmailVerified}');
    log('createdAt: ${user.createdAt}');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingHeader(name: user.getInitials()),
          const SizedBox(height: 24),
          if (hasConsumption)
            EnergySummaryCard(
              period: currentPeriod,
              chartData: energyProvider.monthlyConsumptionData,
              onViewDetails: () => homeProvider.onItemTapped(3),
            )
          else
            EmptyConsumptionState(
                onAddReading: () => homeProvider.onItemTapped(2)),
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          QuickActionsGrid(onTap: (index) {
            final map = {0: 1, 1: 2, 2: 3};
            if (map.containsKey(index)) {
              homeProvider.onItemTapped(map[index]!);
            }
          }),
          const SizedBox(height: 24),
          RecentAppliancesList(
            appliances: appliances,
            onViewAll: () => homeProvider.onItemTapped(1),
          ),
          if (!hasAppliances)
            EmptyAppliancesState(
                onAddAppliance: () => homeProvider.onItemTapped(1)),
          const SizedBox(height: 24),
          Text('Energy Saving Tips',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          EnergyTipsCard(tips: AppConstants.energySavingTips),
        ],
      ),
    );
  }
}
