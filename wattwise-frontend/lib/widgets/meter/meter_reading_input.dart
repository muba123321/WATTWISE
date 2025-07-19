import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'billing_form.dart';
import 'image_uploader.dart';
import 'source_selector.dart';
import 'reading_type_selector.dart';
import 'package:wattwise/models/meter_reading_model.dart';

class MeterReadingInput extends StatefulWidget {
  final Function(
    double reading,
    DateTime timestamp,
    String readingType,
    ReadingSource source, {
    String? notes,
    BillingCycle? billingCycle,
  }) onSubmit;

  final VoidCallback onCancel;

  const MeterReadingInput({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<MeterReadingInput> createState() => _MeterReadingInputState();
}

class _MeterReadingInputState extends State<MeterReadingInput> {
  final _formKey = GlobalKey<FormState>();
  final _readingController = TextEditingController();
  final _notesController = TextEditingController();
  final _billingAmountController = TextEditingController();
  final _billingRateController = TextEditingController();
  final _currencyController = TextEditingController(text: '\$');

  final List<String> _readingTypes = ['electricity', 'gas', 'water', 'other'];

  String _selectedReadingType = 'electricity';
  ReadingSource _selectedSource = ReadingSource.manual;
  bool _hasBillingCycle = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _billingStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _billingEnd = DateTime.now();

  File? _imageFile;
  String _errorMessage = '';

  @override
  void dispose() {
    _readingController.dispose();
    _notesController.dispose();
    _billingAmountController.dispose();
    _billingRateController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final reading = double.parse(_readingController.text);
      final timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      BillingCycle? billingCycle;
      if (_selectedSource == ReadingSource.bill && _hasBillingCycle) {
        billingCycle = BillingCycle(
          startDate: _billingStart,
          endDate: _billingEnd,
          amount: double.parse(_billingAmountController.text),
          currency: _currencyController.text,
          rate: double.parse(_billingRateController.text),
        );
      }

      widget.onSubmit(
        reading,
        timestamp,
        _selectedReadingType,
        _selectedSource,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        billingCycle: billingCycle,
      );
    } catch (e) {
      setState(() => _errorMessage = 'Submission error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meter Reading'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage.isNotEmpty) _buildErrorBox(),
              ReadingTypeSelector(
                readingTypes: _readingTypes,
                selectedType: _selectedReadingType,
                onChanged: (val) => setState(() => _selectedReadingType = val),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _readingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Meter Reading',
                  border: const OutlineInputBorder(),
                  suffixText: _getReadingUnit(),
                ),
                validator: _validateReading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker()),
                ],
              ),
              const SizedBox(height: 24),
              SourceSelector(
                selectedSource: _selectedSource,
                onSourceChanged: (val) => setState(() => _selectedSource = val),
                onPickFromGallery: () => _pickImage(ImageSource.gallery),
                onPickFromCamera: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 24),
              if (_selectedSource == ReadingSource.camera)
                ImageUploader(
                  imageFile: _imageFile,
                  onPickFromCamera: () => _pickImage(ImageSource.camera),
                  onPickFromGallery: () => _pickImage(ImageSource.gallery),
                ),
              const SizedBox(height: 24),
              if (_selectedSource == ReadingSource.bill) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Billing Information',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _hasBillingCycle,
                      onChanged: (val) =>
                          setState(() => _hasBillingCycle = val),
                    ),
                  ],
                ),
                if (_hasBillingCycle)
                  BillingForm(
                    startDate: _billingStart,
                    endDate: _billingEnd,
                    currencyController: _currencyController,
                    amountController: _billingAmountController,
                    rateController: _billingRateController,
                    readingType: _selectedReadingType,
                    onSelectStartDate: () => _pickDate(isStart: true),
                    onSelectEndDate: () => _pickDate(isStart: false),
                  ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Save Reading'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red.shade900),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time),
        ),
        child: Text(_selectedTime.format(context)),
      ),
    );
  }

  String _getReadingUnit() {
    switch (_selectedReadingType.toLowerCase()) {
      case 'electricity':
        return 'kWh';
      case 'gas':
        return 'm³';
      case 'water':
        return 'gal';
      default:
        return 'units';
    }
  }

  String? _validateReading(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a reading';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0) return 'Enter a valid number';
    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _billingStart : _billingEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _billingStart = picked;
        } else {
          _billingEnd = picked;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _selectedSource = ReadingSource.camera;
      });
    }
  }
}
