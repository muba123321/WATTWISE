import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wattwise/models/meter_reading_model.dart';

class MeterReadingCard extends StatelessWidget {
  final MeterReading reading;
  final void Function(String id) onDelete;
  const MeterReadingCard(
      {super.key, required this.reading, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    final statusColor = _getStatusColor(reading.status);
    final statusText = _getStatusText(reading.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeIcon(reading.readingType),
                Text(
                  '${reading.reading.toStringAsFixed(1)} kWh',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                _buildStatusChip(statusText, statusColor),
              ],
            ),
            const SizedBox(height: 16),
            // Date & source
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(dateFormat.format(reading.timestamp),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 16),
                Icon(_getSourceIcon(reading.source), size: 16),
                const SizedBox(width: 4),
                Text(_getSourceText(reading.source),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            // Notes
            if (reading.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.note, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reading.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => onDelete(reading.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    final color = _getReadingTypeColor(type);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(_getReadingTypeIcon(type), color: color),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16)),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getReadingTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'electricity':
        return Colors.yellow.shade800;
      case 'gas':
        return Colors.blue.shade700;
      case 'water':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }

  IconData _getReadingTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'electricity':
        return Icons.electric_bolt;
      case 'gas':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.devices_other;
    }
  }

  IconData _getSourceIcon(ReadingSource source) {
    switch (source) {
      case ReadingSource.manual:
        return Icons.edit;
      case ReadingSource.bill:
        return Icons.receipt;
      case ReadingSource.camera:
        return Icons.camera_alt;
      case ReadingSource.smartMeter:
        return Icons.wifi;
    }
  }

  String _getSourceText(ReadingSource source) {
    switch (source) {
      case ReadingSource.manual:
        return 'Manual Entry';
      case ReadingSource.bill:
        return 'Bill';
      case ReadingSource.camera:
        return 'Camera';
      case ReadingSource.smartMeter:
        return 'Smart Meter';
    }
  }

  Color _getStatusColor(MeterReadingStatus status) {
    switch (status) {
      case MeterReadingStatus.verified:
        return Colors.green;
      case MeterReadingStatus.unverified:
        return Colors.orange;
      case MeterReadingStatus.estimated:
        return Colors.blue;
      case MeterReadingStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText(MeterReadingStatus status) {
    switch (status) {
      case MeterReadingStatus.verified:
        return 'Verified';
      case MeterReadingStatus.unverified:
        return 'Unverified';
      case MeterReadingStatus.estimated:
        return 'Estimated';
      case MeterReadingStatus.error:
        return 'Error';
    }
  }
}
