import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyAppliancesState extends StatelessWidget {
  final VoidCallback onAddAppliance;

  const EmptyAppliancesState({super.key, required this.onAddAppliance});

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
              'No appliances added yet',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your home appliances to track their energy consumption',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddAppliance,
              icon: const Icon(Icons.add),
              label: const Text('Add Appliance'),
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
  <rect x="30" y="40" width="60" height="60" rx="4" fill="#E0E0E0" />
  <rect x="40" y="50" width="40" height="20" rx="2" fill="#9E9E9E" />
  <circle cx="50" cy="85" r="5" fill="#9E9E9E" />
  <circle cx="70" cy="85" r="5" fill="#9E9E9E" />
  <path d="M60 20 L80 40 M60 20 L40 40" stroke="#4CAF50" stroke-width="2" />
</svg>
''';
}
