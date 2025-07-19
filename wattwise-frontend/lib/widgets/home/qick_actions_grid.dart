import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final void Function(int index) onTap;

  const QuickActionsGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final actions = [
      ('Add Appliance', Icons.add_circle, Colors.green),
      ('Add Meter Reading', Icons.electric_meter, Colors.blue),
      ('View Analytics', Icons.insert_chart, Colors.purple),
      ('Set Energy Goal', Icons.emoji_events, Colors.amber),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final (label, icon, color) = actions[index];

        return InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
