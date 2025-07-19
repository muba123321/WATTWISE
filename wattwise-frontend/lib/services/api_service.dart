import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/services/auth_service.dart';

import '../config/app_constants.dart';
import '../models/appliance_model.dart';
import '../models/meter_reading_model.dart';
import '../models/energy_consumption_model.dart';

class ApiService {
  final AuthService _authService;
  bool _isUsingFirebase = false;

  ApiService(this._authService, {bool isUsingFirebase = false}) {
    _isUsingFirebase = isUsingFirebase;
  }

  // Helper method to get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    // In development mode, use the X-Dev-Mode header
    if (!_isUsingFirebase) {
      return {
        'X-Dev-Mode': 'true',
        'Content-Type': 'application/json',
      };
    }

    // In production mode with Firebase, use the Bearer token
    final token = await _authService.idToken;

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Generic GET request
  Future<dynamic> _get(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  // Generic POST request
  Future<dynamic> _post(String endpoint, dynamic data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to post data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> _put(String endpoint, dynamic data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to update data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  // Generic DELETE request
  Future<dynamic> _delete(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return true;
      } else {
        throw Exception(
            'Failed to delete data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }

  // Multipart POST request for file uploads
  Future<dynamic> _uploadFile(String endpoint, Map<String, dynamic> fields,
      File file, String fileField) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // In development mode, use the X-Dev-Mode header
      if (!_isUsingFirebase) {
        request.headers['X-Dev-Mode'] = 'true';
      } else {
        // In production mode with Firebase, use the Bearer token
        final token = await _authService.idToken;

        if (token == null) {
          throw Exception('Authentication token is missing');
        }

        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      final fileExtension = path.extension(file.path).replaceAll('.', '');
      final contentType = _getContentType(fileExtension);

      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
          contentType: contentType,
        ),
      );

      // Add other fields
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to upload file: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('File upload error: $e');
    }
  }

  MediaType _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // User API methods
  Future<User> updateUserProfile(Map<String, dynamic> profileData,
      {File? profileImage}) async {
    try {
      if (profileImage != null) {
        final result = await _uploadFile(
          ApiConstants.profile,
          profileData,
          profileImage,
          'profileImage',
        );
        return User.fromJson(result);
      } else {
        final result = await _put(ApiConstants.profile, profileData);
        return User.fromJson(result);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  Future<User> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final result =
          await _put('${ApiConstants.user}/preferences', preferences);
      return User.fromJson(result);
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  Future<List<EnergyGoal>> getUserGoals() async {
    try {
      final result = await _get(ApiConstants.goals);
      return (result as List).map((goal) => EnergyGoal.fromJson(goal)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user goals: $e');
    }
  }

  Future<EnergyGoal> createGoal(Map<String, dynamic> goalData) async {
    try {
      final result = await _post(ApiConstants.goals, goalData);
      return EnergyGoal.fromJson(result);
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  Future<EnergyGoal> updateGoal(
      String goalId, Map<String, dynamic> goalData) async {
    try {
      final result = await _put('${ApiConstants.goals}/$goalId', goalData);
      return EnergyGoal.fromJson(result);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      return await _delete('${ApiConstants.goals}/$goalId');
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  // Appliance API methods
  Future<List<Appliance>> getAppliances() async {
    try {
      final result = await _get(ApiConstants.appliances);
      if (result is Map && result.containsKey('appliances')) {
        return (result['appliances'] as List)
            .map((appliance) => Appliance.fromJson(appliance))
            .toList();
      } else if (result is List) {
        return result
            .map((appliance) => Appliance.fromJson(appliance))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appliances: $e');
    }
  }

  Future<Appliance> getApplianceById(String id) async {
    try {
      final result = await _get('${ApiConstants.appliances}/$id');
      if (result is Map && result.containsKey('appliance')) {
        return Appliance.fromJson(result['appliance']);
      }
      return Appliance.fromJson(result);
    } catch (e) {
      throw Exception('Failed to fetch appliance: $e');
    }
  }

  Future<Appliance> addAppliance(Map<String, dynamic> applianceData,
      {File? image}) async {
    try {
      if (image != null) {
        final result = await _uploadFile(
          ApiConstants.appliances,
          applianceData,
          image,
          'image',
        );
        return Appliance.fromJson(result);
      } else {
        final result = await _post(ApiConstants.appliances, applianceData);
        return Appliance.fromJson(result);
      }
    } catch (e) {
      throw Exception('Failed to add appliance: $e');
    }
  }

  Future<Appliance> updateAppliance(
      String id, Map<String, dynamic> applianceData,
      {File? image}) async {
    try {
      if (image != null) {
        final result = await _uploadFile(
          '${ApiConstants.appliances}/$id',
          applianceData,
          image,
          'image',
        );
        return Appliance.fromJson(result);
      } else {
        final result =
            await _put('${ApiConstants.appliances}/$id', applianceData);
        return Appliance.fromJson(result);
      }
    } catch (e) {
      throw Exception('Failed to update appliance: $e');
    }
  }

  Future<bool> deleteAppliance(String id) async {
    try {
      return await _delete('${ApiConstants.appliances}/$id');
    } catch (e) {
      throw Exception('Failed to delete appliance: $e');
    }
  }

  Future<List<StandardAppliance>> getStandardAppliances() async {
    try {
      final result = await _get(ApiConstants.standardAppliances);
      if (result is Map && result.containsKey('standardAppliances')) {
        return (result['standardAppliances'] as List)
            .map((appliance) => StandardAppliance.fromJson(appliance))
            .toList();
      } else if (result is List) {
        return result
            .map((appliance) => StandardAppliance.fromJson(appliance))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch standard appliances: $e');
    }
  }

  // Meter reading API methods
  Future<List<MeterReading>> getMeterReadings() async {
    try {
      final result = await _get(ApiConstants.meterReadings);
      if (result is Map && result.containsKey('readings')) {
        return (result['readings'] as List)
            .map((reading) => MeterReading.fromJson(reading))
            .toList();
      } else if (result is List) {
        return result.map((reading) => MeterReading.fromJson(reading)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch meter readings: $e');
    }
  }

  Future<MeterReading> getMeterReadingById(String id) async {
    try {
      final result = await _get('${ApiConstants.meterReadings}/$id');
      if (result is Map && result.containsKey('reading')) {
        return MeterReading.fromJson(result['reading']);
      }
      return MeterReading.fromJson(result);
    } catch (e) {
      throw Exception('Failed to fetch meter reading: $e');
    }
  }

  Future<MeterReading> addMeterReading(Map<String, dynamic> readingData,
      {File? image}) async {
    try {
      if (image != null) {
        final result = await _uploadFile(
          ApiConstants.meterReadings,
          readingData,
          image,
          'image',
        );
        if (result is Map && result.containsKey('meterReading')) {
          return MeterReading.fromJson(result['meterReading']);
        }
        return MeterReading.fromJson(result);
      } else {
        final result = await _post(ApiConstants.meterReadings, readingData);
        if (result is Map && result.containsKey('meterReading')) {
          return MeterReading.fromJson(result['meterReading']);
        }
        return MeterReading.fromJson(result);
      }
    } catch (e) {
      throw Exception('Failed to add meter reading: $e');
    }
  }

  Future<MeterReading> updateMeterReading(
      String id, Map<String, dynamic> readingData,
      {File? image}) async {
    try {
      if (image != null) {
        final result = await _uploadFile(
          '${ApiConstants.meterReadings}/$id',
          readingData,
          image,
          'image',
        );
        if (result is Map && result.containsKey('reading')) {
          return MeterReading.fromJson(result['reading']);
        }
        return MeterReading.fromJson(result);
      } else {
        final result =
            await _put('${ApiConstants.meterReadings}/$id', readingData);
        if (result is Map && result.containsKey('reading')) {
          return MeterReading.fromJson(result['reading']);
        }
        return MeterReading.fromJson(result);
      }
    } catch (e) {
      throw Exception('Failed to update meter reading: $e');
    }
  }

  Future<bool> deleteMeterReading(String id) async {
    try {
      return await _delete('${ApiConstants.meterReadings}/$id');
    } catch (e) {
      throw Exception('Failed to delete meter reading: $e');
    }
  }

  Future<Map<String, dynamic>> calculateConsumption(
      String firstReadingId, String secondReadingId) async {
    try {
      final result = await _get(
          '${ApiConstants.meterReadings}/consumption/$firstReadingId/$secondReadingId');
      return result;
    } catch (e) {
      throw Exception('Failed to calculate consumption: $e');
    }
  }

  // Energy consumption API methods
  Future<List<EnergyConsumption>> getEnergyConsumption(
      {String? period, String? type}) async {
    try {
      String endpoint = ApiConstants.consumption;
      if (period != null || type != null) {
        endpoint += '?';
        if (period != null) {
          endpoint += 'period=$period';
        }
        if (type != null) {
          endpoint += period != null ? '&type=$type' : 'type=$type';
        }
      }

      final result = await _get(endpoint);
      return (result as List)
          .map((consumption) => EnergyConsumption.fromJson(consumption))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch energy consumption: $e');
    }
  }

  Future<ConsumptionPeriod> getCurrentConsumptionPeriod() async {
    try {
      final result = await _get('${ApiConstants.consumption}/current');
      return ConsumptionPeriod.fromJson(result);
    } catch (e) {
      throw Exception('Failed to fetch current consumption period: $e');
    }
  }

  Future<List<ConsumptionPeriod>> getConsumptionPeriods() async {
    try {
      final result = await _get('${ApiConstants.consumption}/periods');
      return (result as List)
          .map((period) => ConsumptionPeriod.fromJson(period))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch consumption periods: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHourlyConsumption() async {
    try {
      final result = await _get('${ApiConstants.consumption}/hourly');
      return (result as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch hourly consumption: $e');
    }
  }

  // Energy-saving tips
  Future<List<String>> getEnergySavingTips() async {
    try {
      final result = await _get(ApiConstants.tips);
      if (result is Map && result.containsKey('tips')) {
        final tipsList = result['tips'] as List;
        // Check if we have full tip objects or just strings
        if (tipsList.isNotEmpty && tipsList.first is Map) {
          // Return just the title of each tip
          return tipsList.map((tip) => tip['title'] as String).toList();
        } else {
          return tipsList.cast<String>();
        }
      } else if (result is List) {
        return result.cast<String>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch energy-saving tips: $e');
    }
  }

  // Get detailed energy saving tips
  Future<List<Map<String, dynamic>>> getDetailedEnergySavingTips(
      {String? category}) async {
    try {
      String endpoint = ApiConstants.tips;
      if (category != null) {
        endpoint += '?category=$category';
      }

      final result = await _get(endpoint);
      if (result is Map && result.containsKey('tips')) {
        return (result['tips'] as List).cast<Map<String, dynamic>>();
      } else if (result is List) {
        return result.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch detailed energy-saving tips: $e');
    }
  }

  // Get appliance-specific tips
  Future<List<Map<String, dynamic>>> getApplianceTips(
      String applianceType) async {
    try {
      final result =
          await _get('${ApiConstants.tips}/appliance/$applianceType');
      if (result is Map && result.containsKey('tips')) {
        return (result['tips'] as List).cast<Map<String, dynamic>>();
      } else if (result is List) {
        return result.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appliance tips: $e');
    }
  }

  // Get a random energy-saving tip
  Future<String> getRandomEnergyTip() async {
    try {
      final result = await _get('${ApiConstants.tips}/random');
      if (result is Map && result.containsKey('tip')) {
        // Check if we have a string or a tip object
        if (result['tip'] is String) {
          return result['tip'] as String;
        } else if (result['tip'] is Map) {
          return result['tip']['title'] as String;
        }
      }
      return 'Turn off appliances when not in use to save energy.';
    } catch (e) {
      throw Exception('Failed to fetch random energy tip: $e');
    }
  }
}
