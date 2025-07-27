import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/providers/goal_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _target = 0;
  String _period = 'monthly';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoalsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("New Energy Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Goal Title"),
              onSaved: (val) => _title = val ?? '',
              validator: (val) =>
                  val == null || val.isEmpty ? 'Title is required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Target (kWh)"),
              keyboardType: TextInputType.number,
              onSaved: (val) => _target = double.tryParse(val ?? '') ?? 0,
              validator: (val) => val == null || double.tryParse(val) == null
                  ? 'Enter a valid number'
                  : null,
            ),
            DropdownButtonFormField(
              value: _period,
              decoration: const InputDecoration(labelText: "Time Period"),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text("Daily")),
                DropdownMenuItem(value: 'weekly', child: Text("Weekly")),
                DropdownMenuItem(value: 'monthly', child: Text("Monthly")),
              ],
              onChanged: (val) => setState(() {
                _period = val!;
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  final DateTime start = DateTime.now();
                  final DateTime end = switch (_period) {
                    'daily' => start.add(const Duration(days: 1)),
                    'weekly' => start.add(const Duration(days: 7)),
                    'monthly' =>
                      DateTime(start.year, start.month + 1, start.day),
                    _ => start.add(const Duration(days: 30)),
                  };

                  final newGoal = EnergyGoal(
                    id: '', // to be replaced by backend
                    title: _title,
                    description: 'Auto-created goal for $_period tracking',
                    targetValue: _target,
                    unit: 'kWh',
                    startDate: start,
                    endDate: end,
                    type: GoalType.reduction,
                    status: GoalStatus.active,
                    currentValue: 0,
                  );

                  await provider.addGoal(newGoal);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save Goal"),
            ),
          ]),
        ),
      ),
    );
  }
}
