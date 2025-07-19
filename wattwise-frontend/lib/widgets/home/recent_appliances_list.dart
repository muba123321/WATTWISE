import 'package:flutter/material.dart';
import 'package:wattwise/models/appliance_model.dart';
import 'package:wattwise/widgets/appliance/appliance_card.dart';

class RecentAppliancesList extends StatelessWidget {
  final List<Appliance> appliances;
  final VoidCallback onViewAll;

  const RecentAppliancesList({
    super.key,
    required this.appliances,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasItems = appliances.isNotEmpty;
    final int displayCount = appliances.length > 3 ? 3 : appliances.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Appliances',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Appliance List
        if (hasItems)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            itemBuilder: (_, index) => ApplianceCard(
              appliance: appliances[index],
            ),
          )
        else
          Text(
            'No recent appliances to show.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
      ],
    );
  }
}
