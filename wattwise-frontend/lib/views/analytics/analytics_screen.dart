import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/analytic_provider.dart';
import 'package:wattwise/widgets/analytics/analytics_content.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsProvider(),
      child: const AnalyticsContent(),
    );
  }
}
