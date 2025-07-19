import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/providers/energy_provider.dart';
import 'package:wattwise/providers/user_provider.dart';

class HomeProvider with ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadInitialData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final userProvider = context.read<UserProvider>();
      final energyProvider = context.read<EnergyProvider>();
      final applianceProvider = context.read<ApplianceProvider>();
      if (userProvider.user == null) {
        log('message....................');
        await userProvider.fetchUserProfile(forceRefresh: false);
      }
      await Future.wait([
        energyProvider.fetchConsumptionData(),
        applianceProvider.fetchAppliances(),
      ]);
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Appliances';
      case 2:
        return 'Meter Readings';
      case 3:
        return 'Analytics';
      case 4:
        return 'Profile';
      default:
        return 'Energy Monitor';
    }
  }
}
