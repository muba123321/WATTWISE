import 'package:wattwise/models/meter_reading_model.dart';
import 'package:wattwise/services/api_service.dart';
import 'package:wattwise/services/auth_service.dart';

class EnergyService {
  final ApiService _api = ApiService(AuthService());

  Future<List<MeterReading>> getMeterReadings() async {
    try {
      return await _api.getMeterReadings();
    } catch (e) {
      throw Exception('EnergyService.getMeterReadings failed: $e');
    }
  }

  Future<void> addMeterReading(MeterReading reading) async {
    try {
      final readingData = {
        'reading': reading.reading,
        'timestamp': reading.timestamp.toIso8601String(),
        'readingType': reading.readingType,
        'source': reading.source.toString().split('.').last,
        'notes': reading.notes,
        'billingCycle': reading.billingCycle?.toJson(),
      };
      await _api.addMeterReading(readingData);
    } catch (e) {
      throw Exception('EnergyService.addMeterReading failed: $e');
    }
  }

  Future<void> deleteMeterReading(String id) async {
    try {
      await _api.deleteMeterReading(id);
    } catch (e) {
      throw Exception('EnergyService.deleteMeterReading failed: $e');
    }
  }
}
