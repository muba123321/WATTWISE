import 'package:flutter/material.dart';
import 'package:wattwise/services/auth_service.dart';

import 'dart:io';

import '../services/api_service.dart';
import '../models/meter_reading_model.dart';
import '../models/energy_consumption_model.dart';

class EnergyProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<MeterReading> _meterReadings = [];
  List<EnergyConsumption> _consumptionData = [];
  List<ConsumptionPeriod> _consumptionPeriods = [];
  ConsumptionPeriod? _currentConsumptionPeriod;
  List<Map<String, dynamic>> _hourlyConsumptionData = [];
  List<String> _energySavingTips = [];
  List<Map<String, dynamic>> _detailedTips = [];

  bool _isLoading = false;
  String? _error;

  EnergyProvider({bool isUsingFirebase = false})
      : _apiService =
            ApiService(AuthService(), isUsingFirebase: isUsingFirebase);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MeterReading> get meterReadings => _meterReadings;
  List<EnergyConsumption> get consumptionData => _consumptionData;
  List<ConsumptionPeriod> get consumptionPeriods => _consumptionPeriods;
  ConsumptionPeriod? get currentConsumptionPeriod => _currentConsumptionPeriod;
  List<Map<String, dynamic>> get hourlyConsumptionData =>
      _hourlyConsumptionData;
  List<String> get energySavingTips => _energySavingTips;
  List<Map<String, dynamic>> get detailedTips => _detailedTips;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Monthly consumption data for charts
  List<Map<String, dynamic>> get monthlyConsumptionData {
    // Group consumption data by month
    final Map<String, double> monthlyData = {};

    for (final consumption in _consumptionData) {
      final monthYear = '${consumption.date.month}-${consumption.date.year}';

      if (monthlyData.containsKey(monthYear)) {
        monthlyData[monthYear] = monthlyData[monthYear]! + consumption.amount;
      } else {
        monthlyData[monthYear] = consumption.amount;
      }
    }

    // Convert to a format suitable for charts
    return monthlyData.entries.map((entry) {
      final parts = entry.key.split('-');
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      final period = '${_getMonthName(month)} $year';

      return {
        'period': period,
        'value': entry.value,
      };
    }).toList();
  }

  // Filter consumption data by type and period
  List<EnergyConsumption> filteredConsumptionData({
    ConsumptionType? type,
    String? period,
  }) {
    if (type == null && period == null) {
      return _consumptionData;
    }

    DateTime? startDate;
    if (period != null) {
      final now = DateTime.now();
      switch (period.toLowerCase()) {
        case 'daily':
          startDate = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 7));
          break;
        case 'weekly':
          startDate = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 30));
          break;
        case 'monthly':
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case 'yearly':
          startDate = DateTime(now.year - 2, now.month, now.day);
          break;
      }
    }

    return _consumptionData.where((consumption) {
      bool typeMatch = type == null || consumption.type == type;
      bool periodMatch =
          startDate == null || consumption.date.isAfter(startDate);
      return typeMatch && periodMatch;
    }).toList();
  }

  // Fetch meter readings
  Future<void> fetchMeterReadings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final readings = await _apiService.getMeterReadings();
      _meterReadings = readings;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new meter reading
  Future<MeterReading?> addMeterReading(
    double reading,
    DateTime timestamp,
    String readingType,
    ReadingSource source, {
    String? notes,
    BillingCycle? billingCycle,
    File? image,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final readingData = {
        'reading': reading,
        'timestamp': timestamp.toIso8601String(),
        'readingType': readingType,
        'source': source.toString().split('.').last,
        'notes': notes,
        'billingCycle': billingCycle?.toJson(),
      };

      final newReading =
          await _apiService.addMeterReading(readingData, image: image);
      _meterReadings.add(newReading);

      // Refresh consumption data since a new reading affects it
      await fetchConsumptionData();

      _isLoading = false;
      notifyListeners();
      return newReading;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete a meter reading
  Future<bool> deleteMeterReading(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteMeterReading(id);

      if (success) {
        _meterReadings.removeWhere((reading) => reading.id == id);

        // Refresh consumption data since deleting a reading affects it
        await fetchConsumptionData();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch energy consumption data
  Future<void> fetchConsumptionData() async {
    _setLoading(true);
    _setError(null);

    try {
      _consumptionData = await _apiService.getEnergyConsumption();
      _consumptionPeriods = await _apiService.getConsumptionPeriods();
      _currentConsumptionPeriod =
          await _apiService.getCurrentConsumptionPeriod();
      _hourlyConsumptionData = await _apiService.getHourlyConsumption();
      _energySavingTips = await _apiService.getEnergySavingTips();

      // Fetch energy-saving tips
      if (_energySavingTips.isEmpty) {
        _energySavingTips = [await _apiService.getRandomEnergyTip()];
      } else {
        // Fetch random tip as fallback
        try {
          final randomTip = await _apiService.getRandomEnergyTip();
          _energySavingTips = [randomTip];
        } catch (tipError) {
          // Use default tips if API fails completely
          _energySavingTips = [
            'Turn off lights when not in use',
            'Unplug electronics when not in use',
            'Use energy-efficient appliances',
            'Reduce standby power consumption',
            'Use natural lighting when possible'
          ];
        }
      }

      // Also fetch detailed tips for future use
      try {
        _detailedTips = await _apiService.getDetailedEnergySavingTips();
      } catch (e) {
        // Silently handle error, we can try again later
        print('Error fetching detailed tips: $e');
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get consumption for a specific period
  ConsumptionPeriod? getConsumptionPeriod(
      DateTime startDate, DateTime endDate) {
    try {
      return _consumptionPeriods.firstWhere((period) =>
          period.startDate.difference(startDate).inDays.abs() <= 2 &&
          period.endDate.difference(endDate).inDays.abs() <= 2);
    } catch (e) {
      return null;
    }
  }

  // Get the latest meter reading
  MeterReading? getLatestMeterReading({String? readingType}) {
    if (_meterReadings.isEmpty) {
      return null;
    }

    final filteredReadings = readingType != null
        ? _meterReadings
            .where((reading) => reading.readingType == readingType)
            .toList()
        : _meterReadings;

    if (filteredReadings.isEmpty) {
      return null;
    }

    // Sort by timestamp, most recent first
    filteredReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filteredReadings.first;
  }

  // Calculate consumption change percentage compared to previous period
  double? getConsumptionChangePercentage() {
    if (_consumptionPeriods.length < 2) {
      return null;
    }

    // Sort periods by end date, most recent first
    final sortedPeriods = List<ConsumptionPeriod>.from(_consumptionPeriods)
      ..sort((a, b) => b.endDate.compareTo(a.endDate));

    final currentPeriod = sortedPeriods[0];
    final previousPeriod = sortedPeriods[1];

    if (previousPeriod.totalConsumption == 0) {
      return null;
    }

    return ((currentPeriod.totalConsumption - previousPeriod.totalConsumption) /
            previousPeriod.totalConsumption) *
        100;
  }

  // Get average daily consumption
  double getAverageDailyConsumption() {
    if (_currentConsumptionPeriod != null &&
        _currentConsumptionPeriod!.averageDaily != null) {
      return _currentConsumptionPeriod!.averageDaily!;
    }

    if (_consumptionData.isEmpty) {
      return 0.0;
    }

    // Calculate average from consumption data
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    final consumptionInPeriod = _consumptionData
        .where((consumption) =>
            consumption.date.isAfter(startDate) &&
            consumption.date.isBefore(endDate))
        .toList();

    if (consumptionInPeriod.isEmpty) {
      return 0.0;
    }

    final totalConsumption = consumptionInPeriod.fold(
        0.0, (sum, consumption) => sum + consumption.amount);

    final daysInPeriod = endDate.difference(startDate).inDays + 1;

    return totalConsumption / daysInPeriod;
  }

  // Get consumption data for a specific day
  List<EnergyConsumption> getConsumptionForDay(DateTime date) {
    return _consumptionData
        .where((consumption) =>
            consumption.date.year == date.year &&
            consumption.date.month == date.month &&
            consumption.date.day == date.day)
        .toList();
  }

  // Get consumption data for a specific month
  List<EnergyConsumption> getConsumptionForMonth(int year, int month) {
    return _consumptionData
        .where((consumption) =>
            consumption.date.year == year && consumption.date.month == month)
        .toList();
  }

  // Get random energy-saving tip
  String getRandomEnergyTip() {
    if (_energySavingTips.isEmpty) {
      return 'Turn off appliances when not in use to save energy.';
    }

    _energySavingTips.shuffle();
    return _energySavingTips.first;
  }

  // Fetch tips by category
  Future<List<Map<String, dynamic>>> getTipsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First check if we already have detailed tips loaded
      if (_detailedTips.isNotEmpty) {
        final filteredTips = _detailedTips
            .where((tip) =>
                tip['category'] == category ||
                (tip['tags'] is List &&
                    (tip['tags'] as List).contains(category)))
            .toList();

        // If we have enough tips, use these
        if (filteredTips.length >= 3) {
          _isLoading = false;
          notifyListeners();
          return filteredTips;
        }
      }

      // Otherwise fetch from API
      final tips =
          await _apiService.getDetailedEnergySavingTips(category: category);

      _isLoading = false;
      notifyListeners();
      return tips;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Fetch appliance-specific tips
  Future<List<Map<String, dynamic>>> getApplianceTips(
      String applianceType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tips = await _apiService.getApplianceTips(applianceType);

      _isLoading = false;
      notifyListeners();
      return tips;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }

    return '';
  }
}
