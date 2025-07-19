import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import '../../models/appliance_model.dart';
import '../../providers/appliance_provider.dart';

class ApplianceDetailScreen extends StatefulWidget {
  final String applianceId;

  const ApplianceDetailScreen({
    super.key,
    required this.applianceId,
  });

  @override
  ApplianceDetailScreenState createState() => ApplianceDetailScreenState();
}

class ApplianceDetailScreenState extends State<ApplianceDetailScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  String _errorMessage = '';

  late TextEditingController _nameController;
  late TextEditingController _dailyUsageController;
  late TextEditingController _roomLocationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dailyUsageController = TextEditingController();
    _roomLocationController = TextEditingController();
    _fetchAppliance();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyUsageController.dispose();
    _roomLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppliance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Provider.of<ApplianceProvider>(context, listen: false)
          .fetchApplianceById(widget.applianceId);
      final appliance = Provider.of<ApplianceProvider>(context, listen: false)
          .getApplianceById(widget.applianceId);

      if (appliance != null) {
        _nameController.text = appliance.name;
        _dailyUsageController.text = appliance.dailyUsageHours.toString();
        _roomLocationController.text = appliance.roomLocation;
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load appliance: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAppliance() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final appliance = Provider.of<ApplianceProvider>(context, listen: false)
          .getApplianceById(widget.applianceId);

      if (appliance != null) {
        final updatedAppliance = Appliance(
          id: appliance.id,
          name: _nameController.text,
          type: appliance.type,
          brand: appliance.brand,
          model: appliance.model,
          powerRatingWatts: appliance.powerRatingWatts,
          standbyPowerWatts: appliance.standbyPowerWatts,
          isSmartDevice: appliance.isSmartDevice,
          imageUrl: appliance.imageUrl,
          dailyUsageHours: double.parse(_dailyUsageController.text),
          efficiency: appliance.efficiency,
          addedDate: appliance.addedDate,
          roomLocation: _roomLocationController.text,
          customFields: appliance.customFields,
        );

        await Provider.of<ApplianceProvider>(context, listen: false)
            .updateAppliance(updatedAppliance);

        setState(() {
          _isEditing = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to update appliance: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAppliance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Appliance'),
        content: const Text(
            'Are you sure you want to delete this appliance? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Provider.of<ApplianceProvider>(context, listen: false)
          .deleteAppliance(widget.applianceId);

      if (mounted) {
        Navigator.of(context).pop(true); // Return to previous screen
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to delete appliance: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name for the appliance';
      });
      return false;
    }

    if (_dailyUsageController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter daily usage hours';
      });
      return false;
    }

    try {
      final hours = double.parse(_dailyUsageController.text);
      if (hours < 0 || hours > 24) {
        setState(() {
          _errorMessage = 'Daily usage hours must be between 0 and 24';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter a valid number for daily usage hours';
      });
      return false;
    }

    if (_roomLocationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a room location';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final applianceProvider = Provider.of<ApplianceProvider>(context);
    final appliance = applianceProvider.getApplianceById(widget.applianceId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Appliance' : 'Appliance Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateAppliance,
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAppliance,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliance == null
              ? Center(
                  child: Text('Appliance not found'),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isEditing
                                ? () => setState(() {
                                      _errorMessage = '';
                                    })
                                : _fetchAppliance,
                            child: Text(_isEditing ? 'OK' : 'Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Appliance header with image
                          _buildApplianceHeader(context, appliance),
                          const SizedBox(height: 24),

                          // Appliance details
                          _isEditing
                              ? _buildEditForm()
                              : _buildApplianceDetails(context, appliance),
                          const SizedBox(height: 24),

                          // Energy consumption
                          if (!_isEditing) ...[
                            Text(
                              'Energy Consumption',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            _buildEnergyConsumptionStats(context, appliance),
                            const SizedBox(height: 24),

                            // Estimated costs
                            Text(
                              'Estimated Costs',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            _buildCostEstimation(context, appliance),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildApplianceHeader(BuildContext context, Appliance appliance) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Appliance image or icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: appliance.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        appliance.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.devices,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.devices,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
            ),
            const SizedBox(width: 16),

            // Appliance name and basic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? _nameController.text : appliance.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appliance.type,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (appliance.brand != null || appliance.model != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (appliance.brand != null) appliance.brand,
                        if (appliance.model != null) appliance.model,
                      ].where((s) => s != null).join(' - '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.power,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${appliance.powerRatingWatts} watts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Appliance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Appliance Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Daily usage hours
            TextFormField(
              controller: _dailyUsageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Usage Hours (0-24)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Room location
            TextFormField(
              controller: _roomLocationController,
              decoration: const InputDecoration(
                labelText: 'Room Location',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplianceDetails(BuildContext context, Appliance appliance) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appliance Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Power Rating',
              '${appliance.powerRatingWatts} watts',
              Icons.power,
            ),
            _buildDetailRow(
              context,
              'Standby Power',
              '${appliance.standbyPowerWatts} watts',
              Icons.power_off,
            ),
            _buildDetailRow(
              context,
              'Daily Usage',
              '${appliance.dailyUsageHours} hours/day',
              Icons.access_time,
            ),
            _buildDetailRow(
              context,
              'Room Location',
              appliance.roomLocation,
              Icons.room,
            ),
            _buildDetailRow(
              context,
              'Efficiency',
              appliance.efficiency.toString().split('.').last.toUpperCase(),
              Icons.eco,
            ),
            _buildDetailRow(
              context,
              'Smart Device',
              appliance.isSmartDevice ? 'Yes' : 'No',
              Icons.smart_toy,
            ),
            _buildDetailRow(
              context,
              'Added Date',
              dateFormat.format(appliance.addedDate),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyConsumptionStats(
      BuildContext context, Appliance appliance) {
    final dailyConsumption = appliance.calculateDailyConsumption();
    final monthlyConsumption = appliance.calculateMonthlyConsumption();
    final annualConsumption = appliance.calculateAnnualConsumption();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildConsumptionStat(
                  context,
                  'Daily',
                  '${dailyConsumption.toStringAsFixed(2)} kWh',
                ),
                _buildConsumptionStat(
                  context,
                  'Monthly',
                  '${monthlyConsumption.toStringAsFixed(2)} kWh',
                ),
                _buildConsumptionStat(
                  context,
                  'Yearly',
                  '${annualConsumption.toStringAsFixed(2)} kWh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Standby consumption
            ...[
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.power_off,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Monthly Standby Consumption:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${appliance.calculateStandbyConsumption().toStringAsFixed(2)} kWh',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildConsumptionStat(
      BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildCostEstimation(BuildContext context, Appliance appliance) {
    // Assumed average electricity rate (can be replaced with actual rate from user settings)
    const double electricityRate = 0.15; // $0.15 per kWh

    final monthlyCost =
        appliance.calculateMonthlyConsumption() * electricityRate;
    final yearlyCost = appliance.calculateAnnualConsumption() * electricityRate;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Based on average rate of \$${electricityRate.toStringAsFixed(2)}/kWh',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCostStat(
                  context,
                  'Monthly Cost',
                  '\$${monthlyCost.toStringAsFixed(2)}',
                ),
                _buildCostStat(
                  context,
                  'Yearly Cost',
                  '\$${yearlyCost.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Energy-saving tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reducing usage by 1 hour daily could save approximately \$${(appliance.powerRatingWatts / 1000 * electricityRate * 30).toStringAsFixed(2)} monthly.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }
}
