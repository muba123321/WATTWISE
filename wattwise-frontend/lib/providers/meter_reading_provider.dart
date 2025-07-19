// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:wattwise/models/meter_reading_model.dart';
// import 'package:wattwise/services/energy_services.dart';

// class MeterReadingProvider with ChangeNotifier {
//   final EnergyService _service = EnergyService();

//   List<MeterReading> _readings = [];
//   List<MeterReading> get readings => _readings;

//   bool isLoading = false;
//   String errorMessage = '';

//   Future<void> fetchReadings() async {
//     _setLoading(true);
//     errorMessage = '';

//     try {
//       _readings = await _service.getMeterReadings();
//     } catch (e) {
//       errorMessage = 'Failed to load meter readings: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> addReading(
//     double value,
//     DateTime timestamp,
//     String type,
//     ReadingSource source, {
//     String? notes,
//     BillingCycle? billingCycle,
//   }) async {
//     _setLoading(true);
//     errorMessage = '';

//     try {
//       final reading = MeterReading(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         reading: value,
//         timestamp: timestamp,
//         readingType: type,
//         source: source,
//         status: MeterReadingStatus.unverified,
//         notes: notes,
//         userId: '',
//         billingCycle: billingCycle,
//       );

//       await _service.addMeterReading(reading);
//       await fetchReadings();
//     } catch (e) {
//       errorMessage = 'Failed to add reading: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> deleteReading(String id) async {
//     _setLoading(true);
//     errorMessage = '';

//     try {
//       await _service.deleteMeterReading(id);
//       await fetchReadings();
//     } catch (e) {
//       errorMessage = 'Failed to delete reading: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void _setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }

//   void clearError() {
//     errorMessage = '';
//     notifyListeners();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wattwise/models/meter_reading_model.dart';
import 'package:wattwise/services/energy_services.dart';

class MeterReadingProvider with ChangeNotifier {
  final EnergyService _service;
  MeterReadingProvider({EnergyService? service})
      : _service = service ?? EnergyService();

  List<MeterReading> _readings = [];
  List<MeterReading> get readings => _readings;

  bool isLoading = false;
  String errorMessage = '';
  bool isAdding = false;

  Future<void> fetchReadings() async {
    _setLoading(true);
    errorMessage = '';

    try {
      _readings = await _service.getMeterReadings();
    } catch (e) {
      errorMessage = 'Failed to load meter readings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addReading(
    double value,
    DateTime timestamp,
    String type,
    ReadingSource source, {
    String? notes,
    BillingCycle? billingCycle,
  }) async {
    _setLoading(true);
    errorMessage = '';

    try {
      final reading = MeterReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reading: value,
        timestamp: timestamp,
        readingType: type,
        source: source,
        status: MeterReadingStatus.unverified,
        notes: notes,
        userId: '',
        billingCycle: billingCycle,
      );

      await _service.addMeterReading(reading);
      await fetchReadings();
      toggleAddReading();
    } catch (e) {
      errorMessage = 'Failed to add reading: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReading(String id) async {
    _setLoading(true);
    errorMessage = '';

    try {
      await _service.deleteMeterReading(id);
      await fetchReadings();
    } catch (e) {
      errorMessage = 'Failed to delete reading: $e';
    } finally {
      _setLoading(false);
    }
  }

  void toggleAddReading() {
    isAdding = !isAdding;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearError() {
    errorMessage = '';
    notifyListeners();
  }
}
