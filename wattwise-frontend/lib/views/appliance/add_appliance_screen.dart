import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/appliance_provider.dart';
import '../../models/appliance_model.dart';

class AddApplianceScreen extends StatefulWidget {
  const AddApplianceScreen({super.key});

  @override
  AddApplianceScreenState createState() => AddApplianceScreenState();
}

class AddApplianceScreenState extends State<AddApplianceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _power = TextEditingController();
  final _standby = TextEditingController();
  final _usage = TextEditingController();
  final _room = TextEditingController();
  File? _image;
  String _type = 'Refrigerator';
  bool _isSmart = false;
  ApplianceEfficiency _efficiency = ApplianceEfficiency.medium;

  bool _useStandardAppliance = false;

  List<StandardAppliance> _standardAppliances = [];
  StandardAppliance? _selectedStandardAppliance;
  bool _loading = false;
  String? _error;
  // bool _isLoading = false;
  // String _errorMessage = '';
  bool _isLoadingStandardAppliances = true;
  final _types = [
    'Refrigerator',
    'Washing Machine',
    'Dishwasher',
    'Air Conditioner',
    'TV',
    'Computer',
    'Lighting',
    'Oven',
    'Microwave',
    'Water Heater',
    'Fan',
    'Other'
  ];
  // final List<String> _applianceTypes = [
  //   'Refrigerator',
  //   'Washing Machine',
  //   'Dishwasher',
  //   'Air Conditioner',
  //   'TV',
  //   'Computer',
  //   'Lighting',
  //   'Oven',
  //   'Microwave',
  //   'Water Heater',
  //   'Fan',
  //   'Other'
  // ];

  @override
  void initState() {
    super.initState();
    _fetchStandardAppliances();
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _model.dispose();
    _power.dispose();
    _standby.dispose();
    _usage.dispose();
    _room.dispose();
    super.dispose();
  }

  Future<void> _fetchStandardAppliances() async {
    setState(() {
      _isLoadingStandardAppliances = true;
    });

    try {
      final provider = context.read<ApplianceProvider>();
      await provider.fetchStandardAppliances();
      setState(() {
        _standardAppliances = provider.standardAppliances;
      });
    } catch (error) {
      print('Error fetching standard appliances: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStandardAppliances = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _applyStandardAppliance(StandardAppliance standardAppliance) {
    setState(() {
      _selectedStandardAppliance = standardAppliance;
      _name.text = standardAppliance.name;
      _type = standardAppliance.type;
      _power.text = standardAppliance.averagePowerRating.toString();
      if (standardAppliance.standbyPower != null) {
        _standby.text = standardAppliance.standbyPower.toString();
      }
    });
  }

  Future<void> _saveAppliance() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ApplianceProvider>();
    setState(() => _loading = true);

    // Create a new appliance
    final newAppliance = Appliance(
      id: '',
      name: _name.text,
      type: _type,
      brand: _brand.text.isEmpty ? null : _brand.text,
      model: _model.text.isEmpty ? null : _model.text,
      powerRatingWatts: double.parse(_power.text),
      standbyPowerWatts: double.parse(_standby.text),
      isSmartDevice: _isSmart,
      dailyUsageHours: double.parse(_usage.text),
      efficiency: _efficiency,
      addedDate: DateTime.now(),
      roomLocation: _room.text,
      customFields: null,
    );

    final result = await provider.addAppliance(newAppliance, image: _image);

    if (!result && mounted) {
      Navigator.pop(context);
    } else {
      setState(() {
        _error = provider.error;
        _loading = false;
      });
    }
  }

  Widget _buildSectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appliance'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use standard appliance option
                    SwitchListTile(
                      title: const Text('Use Standard Appliance Template'),
                      subtitle:
                          const Text('Choose from common household appliances'),
                      value: _useStandardAppliance,
                      onChanged: (value) {
                        setState(() {
                          _useStandardAppliance = value;
                        });
                      },
                    ),

                    // Standard appliance selector
                    if (_useStandardAppliance) ...[
                      const SizedBox(height: 16),
                      if (_isLoadingStandardAppliances)
                        const Center(child: CircularProgressIndicator())
                      else if (_standardAppliances.isEmpty)
                        const Text(
                            'No standard appliances available. Please add manually.')
                      else
                        DropdownButtonFormField<StandardAppliance>(
                          decoration: const InputDecoration(
                            labelText: 'Select Standard Appliance',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedStandardAppliance,
                          items: _standardAppliances.map((appliance) {
                            return DropdownMenuItem<StandardAppliance>(
                              value: appliance,
                              child: Text(
                                  '${appliance.name} (${appliance.averagePowerRating}W)'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _applyStandardAppliance(value);
                            }
                          },
                        ),
                    ],

                    const SizedBox(height: 24),

                    // Error message
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_error!,
                                    style: const TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 16),
                    ],

                    // Image upload
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Upload Image'),
                          ),
                        ),
                        if (_image != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Basic Info'),
                    // Appliance name
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Appliance Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Appliance type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Appliance Type *',
                        border: OutlineInputBorder(),
                      ),
                      value: _type,
                      items: _types
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _type = val!),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please select a type'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    _buildSectionTitle('Brand & Model'),
                    // Brand and model (optional)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _brand,
                            decoration: const InputDecoration(
                              labelText: 'Brand (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _model,
                            decoration: const InputDecoration(
                              labelText: 'Model (Optional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Power ratings
                    _buildSectionTitle('Power Details'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _power,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Power Rating (W) *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final num = double.tryParse(v ?? '');
                              return (num == null || num <= 0)
                                  ? 'Enter valid number'
                                  : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _standby,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Standby Power (W)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              final num = double.tryParse(v ?? '');
                              return (num == null || num <= 0)
                                  ? 'Enter valid number'
                                  : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Daily usage
                    TextFormField(
                      controller: _usage,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Usage (hrs/day) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final num = double.tryParse(v ?? '');
                        return (num == null || num < 0 || num > 24)
                            ? 'Between 0 and 24'
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Location & Settings'),
                    // Room location
                    TextFormField(
                      controller: _room,
                      decoration: const InputDecoration(
                        labelText: 'Room Location *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),

                    _buildSectionTitle('Energy Efficiency'),
                    // Energy efficiency
                    // const Text(
                    //   'Energy Efficiency:',
                    //   style: TextStyle(fontSize: 16),
                    // ),
                    // const SizedBox(height: 8),
                    SegmentedButton<ApplianceEfficiency>(
                      segments: const [
                        ButtonSegment<ApplianceEfficiency>(
                          value: ApplianceEfficiency.low,
                          label: Text('Low'),
                        ),
                        ButtonSegment<ApplianceEfficiency>(
                          value: ApplianceEfficiency.medium,
                          label: Text('Medium'),
                        ),
                        ButtonSegment<ApplianceEfficiency>(
                          value: ApplianceEfficiency.high,
                          label: Text('High'),
                        ),
                      ],
                      selected: {_efficiency},
                      onSelectionChanged: (val) =>
                          setState(() => _efficiency = val.first),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Image'),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Select Image"),
                        ),
                        const SizedBox(width: 10),
                        if (_image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_image!,
                                width: 60, height: 60, fit: BoxFit.cover),
                          )
                      ],
                    ),
                    // Smart device
                    SwitchListTile(
                      title: const Text('Smart Device'),
                      subtitle: const Text(
                          'Can be controlled remotely or has smart features'),
                      value: _isSmart,
                      onChanged: (value) {
                        setState(() {
                          _isSmart = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton.icon(
                      onPressed: _saveAppliance,
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        maximumSize: const Size.fromHeight(48),
                        // padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      label: const Text('Save Appliance'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
