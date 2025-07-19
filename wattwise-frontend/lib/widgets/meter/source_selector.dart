import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wattwise/models/meter_reading_model.dart';

class SourceSelector extends StatelessWidget {
  final ReadingSource selectedSource;
  final ValueChanged<ReadingSource> onSourceChanged;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;

  const SourceSelector({
    super.key,
    required this.selectedSource,
    required this.onSourceChanged,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip(
          context,
          label: 'Manual',
          icon: Icons.edit,
          source: ReadingSource.manual,
          tooltip: 'Enter manually',
        ),
        _buildChip(
          context,
          label: 'Bill',
          icon: Icons.receipt_long,
          source: ReadingSource.bill,
          tooltip: 'Upload from bill',
        ),
        _buildChip(
          context,
          label: 'Camera',
          icon: Icons.camera_alt,
          source: ReadingSource.camera,
          tooltip: 'Capture with camera',
          onTap: () {
            HapticFeedback.selectionClick();
            onSourceChanged(ReadingSource.camera);
            _showCameraOptions(context);
          },
        ),
        _buildChip(
          context,
          label: 'Smart Meter',
          icon: Icons.wifi,
          source: ReadingSource.smartMeter,
          tooltip: 'Fetch from smart meter',
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ReadingSource source,
    String? tooltip,
    VoidCallback? onTap,
  }) {
    final isSelected = selectedSource == source;

    return Tooltip(
      message: tooltip ?? label,
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(
          icon,
          color: isSelected ? Colors.white : Theme.of(context).primaryColor,
        ),
        selected: isSelected,
        selectedColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.grey.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          HapticFeedback.selectionClick();
          if (onTap != null) {
            onTap();
          } else {
            onSourceChanged(source);
          }
        },
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
