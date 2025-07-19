import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingForm extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController currencyController;
  final TextEditingController amountController;
  final TextEditingController rateController;
  final String readingType;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const BillingForm({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.currencyController,
    required this.amountController,
    required this.rateController,
    required this.readingType,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing Period', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),

            // Billing date range
            Row(
              children: [
                Expanded(
                    child: _buildDatePicker(
                        context, 'Start Date', startDate, onSelectStartDate)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDatePicker(
                        context, 'End Date', endDate, onSelectEndDate)),
              ],
            ),
            const SizedBox(height: 16),

            // Billing amount
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Billing Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      if (value != null &&
                          value.isNotEmpty &&
                          (amount == null || amount <= 0)) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rate per unit
            TextFormField(
              controller: rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Rate per Unit',
                border: const OutlineInputBorder(),
                suffixText: _getUnitSuffix(readingType),
              ),
              validator: (value) {
                final rate = double.tryParse(value ?? '');
                if (value != null &&
                    value.isNotEmpty &&
                    (rate == null || rate <= 0)) {
                  return 'Enter a valid rate';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  String _getUnitSuffix(String type) {
    switch (type.toLowerCase()) {
      case 'electricity':
        return '/kWh';
      case 'gas':
        return '/m³';
      case 'water':
        return '/gal';
      default:
        return '/unit';
    }
  }
}
