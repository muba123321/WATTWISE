import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/widgets/profile/goal_stat.dart';

class GoalCard extends StatelessWidget {
  final EnergyGoal goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    // Determine status color
    Color statusColor;
    switch (goal.status) {
      case GoalStatus.active:
        statusColor = Colors.blue;
        break;
      case GoalStatus.completed:
        statusColor = Colors.green;
        break;
      case GoalStatus.failed:
        statusColor = Colors.red;
        break;
    }

    // Determine progress color
    Color progressColor;
    if (goal.progressPercentage >= 100) {
      progressColor = Colors.green;
    } else if (goal.progressPercentage >= 60) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Goal title
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Goal status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    goal.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Goal description
            Text(
              goal.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Goal progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          // Background
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Progress fill
                          FractionallySizedBox(
                            widthFactor: goal.progressPercentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal details
            Row(
              children: [
                GoalStat(
                  label: 'Target',
                  value: '${goal.targetValue} ${goal.unit}',
                  icon: Icons.flag,
                ),
                GoalStat(
                  label: 'Current',
                  value: '${goal.currentValue} ${goal.unit}',
                  icon: Icons.trending_up,
                ),
                GoalStat(
                  label: 'Deadline',
                  value: dateFormat.format(goal.endDate),
                  icon: Icons.event,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
