import 'package:flutter/material.dart';
import 'package:wattwise/services/auth_service.dart';
import 'dart:io';

import '../services/api_service.dart';

import '../models/appliance_model.dart';

class ApplianceProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Appliance> _appliances = [];
  List<StandardAppliance> _standardAppliances = [];
  bool _isLoading = false;
  String? _error;

  ApplianceProvider({bool isUsingFirebase = false})
      : _apiService =
            ApiService(AuthService(), isUsingFirebase: isUsingFirebase);

  // Getters
  List<Appliance> get appliances => _appliances;
  List<StandardAppliance> get standardAppliances => _standardAppliances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // 🔄 Fetch All Appliances
  Future<void> fetchAppliances() async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _apiService.getAppliances();
      _appliances = result;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Fetch standard appliances
  Future<void> fetchStandardAppliances() async {
    _setLoading(true);
    _setError(null);
    try {
      final appliances = await _apiService.getStandardAppliances();
      _standardAppliances = appliances;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get appliance by ID
  Appliance? getApplianceById(String id) {
    try {
      return _appliances.firstWhere((appliance) => appliance.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch appliance by ID from API
  Future<Appliance?> fetchApplianceById(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final appliance = await _apiService.getApplianceById(id);

      // Update the appliance in the local list
      final index = _appliances.indexWhere((a) => a.id == id);
      if (index >= 0) {
        _appliances[index] = appliance;
      } else {
        _appliances.add(appliance);
      }
      _setLoading(false);
      return appliance;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

//   void _replaceAppliance(Appliance appliance) {
//   final index = _appliances.indexWhere((a) => a.id == appliance.id);
//   if (index != -1) _appliances[index] = appliance;
//   else _appliances.add(appliance);
//   notifyListeners();
// }

  // ➕ Add New Appliance
  Future<bool> addAppliance(Appliance appliance, {File? image}) async {
    _setLoading(true);
    _setError(null);

    // 1. Add a temporary appliance to UI immediately
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempAppliance = appliance.copyWith(id: tempId);
    _appliances.add(tempAppliance);
    notifyListeners();

    try {
      // 2. Upload to API
      final newAppliance =
          await _apiService.addAppliance(appliance.toJson(), image: image);

      // 3. Replace temp appliance with real one
      final index = _appliances.indexWhere((a) => a.id == tempId);
      if (index != -1) {
        _appliances[index] = newAppliance;
      } else {
        _appliances.add(newAppliance);
      }

      notifyListeners();
      return true;
    } catch (e) {
      // 4. Rollback on failure
      _appliances.removeWhere((a) => a.id == tempId);
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ✏️ Update Appliance
  Future<bool> updateAppliance(Appliance appliance, {File? image}) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _apiService
          .updateAppliance(appliance.id, appliance.toJson(), image: image);

      final index = _appliances.indexWhere((a) => a.id == appliance.id);
      if (index != -1) _appliances[index] = updated;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ❌ Delete Appliance
  Future<bool> deleteAppliance(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      final success = await _apiService.deleteAppliance(id);
      if (success) {
        _appliances.removeWhere((appliance) => appliance.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get appliances by room
  List<Appliance> getAppliancesByRoom(String room) {
    return _appliances
        .where((appliance) =>
            appliance.roomLocation.toLowerCase() == room.toLowerCase())
        .toList();
  }

  // Get appliances by type
  List<Appliance> getAppliancesByType(String type) {
    return _appliances
        .where(
            (appliance) => appliance.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  // Get smart appliances
  List<Appliance> getSmartAppliances() =>
      _appliances.where((appliance) => appliance.isSmartDevice).toList();

  // Get traditional appliances
  List<Appliance> getTraditionalAppliances() =>
      _appliances.where((appliance) => !appliance.isSmartDevice).toList();

  // Get high-consumption appliances
  List<Appliance> getHighConsumptionAppliances() {
    // Sort appliances by daily consumption (descending)
    final sorted = [..._appliances]..sort((a, b) =>
        b.calculateDailyConsumption().compareTo(a.calculateDailyConsumption()));

    // Return top 30% or at least 3 appliances
    final count = (sorted.length * 0.3).ceil();
    return sorted.take(count > 3 ? count : 3).toList();
  }

  // Calculate total daily consumption
  double calculateTotalDailyConsumption() {
    return _appliances.fold(
        0.0, (sum, appliance) => sum + appliance.calculateDailyConsumption());
  }

  // Calculate total monthly consumption
  double calculateTotalMonthlyConsumption() {
    return _appliances.fold(
        0.0, (sum, appliance) => sum + appliance.calculateMonthlyConsumption());
  }

  // Calculate consumption by room
  Map<String, double> calculateConsumptionByRoom() {
    final Map<String, double> roomConsumption = {};

    for (final appliance in _appliances) {
      final room = appliance.roomLocation;
      final consumption = appliance.calculateMonthlyConsumption();
      roomConsumption[room] = (roomConsumption[room] ?? 0.0) + consumption;
    }

    return roomConsumption;
  }

  // Search appliances
  List<Appliance> searchAppliances(String query) {
    final lowerQuery = query.toLowerCase();

    return _appliances
        .where((appliance) =>
            appliance.name.toLowerCase().contains(lowerQuery) ||
            appliance.type.toLowerCase().contains(lowerQuery) ||
            appliance.brand?.toLowerCase().contains(lowerQuery) == true ||
            appliance.model?.toLowerCase().contains(lowerQuery) == true ||
            appliance.roomLocation.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
