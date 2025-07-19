// import 'package:flutter/material.dart';
// import '../../models/appliance_model.dart';
// import '../../config/theme.dart';

// class ApplianceCard extends StatelessWidget {
//   final Appliance appliance;
//   final VoidCallback? onTap;

//   const ApplianceCard({
//     Key? key,
//     required this.appliance,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Appliance Image or Icon
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: appliance.imageUrl != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           appliance.imageUrl!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return _buildApplianceIcon();
//                           },
//                         ),
//                       )
//                     : _buildApplianceIcon(),
//               ),
//               const SizedBox(width: 16),

//               // Appliance Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       appliance.name,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${appliance.type} • ${appliance.roomLocation}',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         _buildInfoChip(
//                           context,
//                           '${appliance.powerRatingWatts}W',
//                           Icons.power,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildInfoChip(
//                           context,
//                           '${appliance.dailyUsageHours}h/day',
//                           Icons.access_time,
//                         ),
//                         const SizedBox(width: 8),
//                         if (appliance.isSmartDevice)
//                           _buildSmartDeviceChip(context),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Energy consumption summary
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '${appliance.calculateDailyConsumption().toStringAsFixed(1)} kWh',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.secondary,
//                         ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'per day',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildApplianceIcon() {
//     return Icon(
//       _getApplianceIcon(appliance.type),
//       size: 24,
//       color: AppColors.primaryGreen,
//     );
//   }

//   Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 12,
//             color: Theme.of(context).colorScheme.secondary,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Theme.of(context).colorScheme.secondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSmartDeviceChip(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.wifi,
//             size: 12,
//             color: Colors.blue,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             'Smart',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getApplianceIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'refrigerator':
//         return Icons.kitchen;
//       case 'washing machine':
//         return Icons.local_laundry_service;
//       case 'dishwasher':
//         return Icons.countertops;
//       case 'air conditioner':
//         return Icons.ac_unit;
//       case 'tv':
//         return Icons.tv;
//       case 'computer':
//         return Icons.computer;
//       case 'lighting':
//         return Icons.lightbulb;
//       case 'oven':
//         return Icons.microwave;
//       case 'microwave':
//         return Icons.microwave;
//       case 'water heater':
//         return Icons.hot_tub;
//       case 'fan':
//         return Icons.toys;
//       default:
//         return Icons.devices;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:wattwise/config/design_system.dart';
import 'package:wattwise/models/appliance_model.dart';

class ApplianceCard extends StatelessWidget {
  final Appliance appliance;
  final VoidCallback? onTap;

  const ApplianceCard({
    super.key,
    required this.appliance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildImageOrIcon(context),
              const SizedBox(width: 16),
              _buildDetails(context),
              _buildConsumption(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOrIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: appliance.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                appliance.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildIcon(),
              ),
            )
          : _buildIcon(),
    );
  }

  Widget _buildIcon() {
    return Icon(
      _getApplianceIcon(appliance.type),
      size: 24,
      color: AppColors.primaryGreen,
    );
  }

  Widget _buildDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appliance.name,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${appliance.type} • ${appliance.roomLocation}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildInfoChip(
                  context, '${appliance.powerRatingWatts}W', Icons.power),
              _buildInfoChip(context, '${appliance.dailyUsageHours}h/day',
                  Icons.access_time),
              if (appliance.isSmartDevice) _buildSmartChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumption(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${appliance.calculateDailyConsumption().toStringAsFixed(1)} kWh',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text('per day', style: textTheme.bodySmall),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartChip(BuildContext context) {
    const blue = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blue.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi, size: 12, color: blue),
          SizedBox(width: 4),
          Text('Smart', style: TextStyle(fontSize: 12, color: blue)),
        ],
      ),
    );
  }

  IconData _getApplianceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'washing machine':
        return Icons.local_laundry_service;
      case 'dishwasher':
        return Icons.countertops;
      case 'air conditioner':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      case 'computer':
        return Icons.computer;
      case 'lighting':
        return Icons.lightbulb;
      case 'oven':
      case 'microwave':
        return Icons.microwave;
      case 'water heater':
        return Icons.hot_tub;
      case 'fan':
        return Icons.toys;
      default:
        return Icons.devices;
    }
  }
}
