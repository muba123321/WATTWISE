import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final SharedPreferences _prefs;

  // Storage keys
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _energyUnitKey = 'energy_unit';
  static const String _currencyKey = 'currency';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationTypesKey = 'notification_types';
  static const String _lastSyncKey = 'last_sync';

  StorageService(this._prefs);

  // User data operations
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await _prefs.setString(_userKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding user data: $e');
      return null;
    }
  }

  Future<bool> clearUserData() async {
    return await _prefs.remove(_userKey);
  }

  // Token operations
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(_tokenKey);
  }

  // Theme operations
  Future<bool> setDarkMode(bool isDarkMode) async {
    return await _prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  bool isDarkMode() {
    return _prefs.getBool(_isDarkModeKey) ?? false;
  }

  // Energy unit operations
  Future<bool> setEnergyUnit(String unit) async {
    return await _prefs.setString(_energyUnitKey, unit);
  }

  String getEnergyUnit() {
    return _prefs.getString(_energyUnitKey) ?? 'kWh';
  }

  // Currency operations
  Future<bool> setCurrency(String currency) async {
    return await _prefs.setString(_currencyKey, currency);
  }

  String getCurrency() {
    return _prefs.getString(_currencyKey) ?? '\$';
  }

  // Notification operations
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<bool> setNotificationTypes(List<String> types) async {
    return await _prefs.setStringList(_notificationTypesKey, types);
  }

  List<String> getNotificationTypes() {
    return _prefs.getStringList(_notificationTypesKey) ?? [];
  }

  // Sync time operations
  Future<bool> setLastSyncTime(DateTime time) async {
    return await _prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeString = _prefs.getString(_lastSyncKey);
    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      print('Error parsing last sync time: $e');
      return null;
    }
  }

  // Clear all data (for logout)
  Future<bool> clearAll() async {
    // Keep theme settings when logging out
    final isDarkMode = this.isDarkMode();
    final energyUnit = getEnergyUnit();
    final currency = getCurrency();

    await _prefs.clear();

    // Restore theme settings
    await setDarkMode(isDarkMode);
    await setEnergyUnit(energyUnit);
    await setCurrency(currency);

    return true;
  }

  // Save general preferences
  Future<bool> savePreferences(Map<String, dynamic> preferences) async {
    bool success = true;

    if (preferences.containsKey('isDarkMode')) {
      success = success && await setDarkMode(preferences['isDarkMode']);
    }

    if (preferences.containsKey('energyUnit')) {
      success = success && await setEnergyUnit(preferences['energyUnit']);
    }

    if (preferences.containsKey('currency')) {
      success = success && await setCurrency(preferences['currency']);
    }

    if (preferences.containsKey('notificationsEnabled')) {
      success = success &&
          await setNotificationsEnabled(preferences['notificationsEnabled']);
    }

    if (preferences.containsKey('notificationTypes')) {
      success = success &&
          await setNotificationTypes(preferences['notificationTypes']);
    }

    return success;
  }

  // Get all preferences
  Map<String, dynamic> getAllPreferences() {
    return {
      'isDarkMode': isDarkMode(),
      'energyUnit': getEnergyUnit(),
      'currency': getCurrency(),
      'notificationsEnabled': getNotificationsEnabled(),
      'notificationTypes': getNotificationTypes(),
    };
  }
}
