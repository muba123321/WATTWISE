import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/widgets/profile/goal_stat.dart';

class GoalCard extends StatelessWidget {
  final EnergyGoal goal;
  final void Function()? onDelete; // 🗑️ Callback to trigger deletion

  const GoalCard({super.key, required this.goal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    Color statusColor = switch (goal.status) {
      GoalStatus.active => Colors.blue,
      GoalStatus.completed => Colors.green,
      GoalStatus.failed => Colors.red,
    };

    Color progressColor = goal.progressPercentage >= 100
        ? Colors.green
        : goal.progressPercentage >= 60
            ? Colors.orange
            : Colors.red;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Goal?'),
            content: const Text('Are you sure you want to delete this goal?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
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
              /// 🏷️ Title & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      goal.status.name.toUpperCase(),
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

              /// 📝 Description
              Text(goal.description,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),

              /// 📊 Progress bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progress',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                              begin: 0, end: goal.progressPercentage),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, _) {
                            return Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: (value / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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

              /// 📅 Stats row
              Row(
                children: [
                  GoalStat(
                    label: 'Start',
                    value: dateFormat.format(goal.startDate),
                    icon: Icons.calendar_month,
                  ),
                  GoalStat(
                    label: 'Deadline',
                    value: dateFormat.format(goal.endDate),
                    icon: Icons.event,
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
