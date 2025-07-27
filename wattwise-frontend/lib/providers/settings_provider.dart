import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final BuildContext context;
  SettingsProvider(this.context);

  bool isLoading = false;
  String errorMessage = '';

  final TextEditingController currencyController = TextEditingController();
  final List<String> energyUnits = ['kWh', 'MJ', 'BTU'];
  final List<String> notificationTypes = [
    'Usage Alerts',
    'Bill Reminders',
    'Goal Updates',
    'Energy Tips',
    'System Updates'
  ];

  Map<String, bool> selectedNotificationTypes = {};
  bool? notificationsEnabled;
  bool? darkMode;
  String? selectedEnergyUnit;

  UserProvider get _userProvider =>
      Provider.of<UserProvider>(context, listen: false);

  Future<void> initialize() async {
    if (_userProvider.user == null) {
      await _userProvider.fetchUserProfile();
    }
    final user = _userProvider.user;
    if (user == null) {
      errorMessage = 'User not found';
      notifyListeners();
      return;
    }

    currencyController.text = user.preferences.currency ?? '\$';
    selectedEnergyUnit = user.preferences.energyUnit;
    notificationsEnabled = user.preferences.notificationsEnabled;
    darkMode = user.preferences.isDarkMode;

    selectedNotificationTypes = {
      for (var type in notificationTypes)
        type: user.preferences.notificationTypes?.contains(type) ?? true
    };
    notifyListeners();
  }

  void toggleNotificationType(String type, bool value) {
    selectedNotificationTypes[type] = value;
    notifyListeners();
  }

  void toggleNotificationsEnabled(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void setEnergyUnit(String unit) {
    selectedEnergyUnit = unit;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    _setLoading(true);
    bool success = false;
    try {
      final user = _userProvider.user;
      if (user == null) throw Exception('User not found');

      final updatedPreferences = user.preferences.copyWith(
        currency:
            currencyController.text.isEmpty ? '\$' : currencyController.text,
        energyUnit: selectedEnergyUnit ?? user.preferences.energyUnit,
        notificationsEnabled:
            notificationsEnabled ?? user.preferences.notificationsEnabled,
        isDarkMode: darkMode ?? user.preferences.isDarkMode,
        notificationTypes: selectedNotificationTypes.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
      );

      await _userProvider.updateUserPreferences(updatedPreferences);
      success = true;
    } catch (e) {
      errorMessage = 'Failed to save settings: $e';
    } finally {
      _setLoading(false);
    }
    return success;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();

    if (!value) {
      Future.delayed(const Duration(seconds: 2), () {
        errorMessage = '';
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }
}
