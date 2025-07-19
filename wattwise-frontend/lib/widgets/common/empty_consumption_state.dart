import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyConsumptionState extends StatelessWidget {
  final VoidCallback onAddReading;

  const EmptyConsumptionState({
    super.key,
    required this.onAddReading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              _svgGraphic,
              width: 120,
              height: 120,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No consumption data yet',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add meter readings to track your energy usage',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddReading,
              icon: const Icon(Icons.bolt),
              label: const Text('Add Reading'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _svgGraphic = '''
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120">
  <rect width="120" height="120" fill="none" />
  <circle cx="60" cy="60" r="50" fill="#F5F5F5" />
  <path d="M60 30 L60 60 L80 80" stroke="#4CAF50" stroke-width="4" stroke-linecap="round" />
  <circle cx="60" cy="60" r="5" fill="#4CAF50" />
  <path d="M85 35 L95 35 M85 45 L95 45 M35 35 L25 35 M35 45 L25 45" stroke="#4CAF50" stroke-width="2" />
</svg>
''';
}
