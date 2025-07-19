import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String name;

  const GreetingHeader({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final theme = Theme.of(context);

    return Text(
      '$greeting $name',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
