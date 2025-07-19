// import 'package:flutter/material.dart';
// import 'package:wattwise/models/energy_consumption_model.dart';
// import 'package:wattwise/providers/energy_provider.dart';
// import 'package:wattwise/providers/appliance_provider.dart';

// class AnalyticsProvider with ChangeNotifier {
//   final EnergyProvider energyProvider;
//   final ApplianceProvider applianceProvider;

//   bool isLoading = true;
//   String errorMessage = '';

//   String selectedPeriod = 'Monthly';
//   ConsumptionType selectedType = ConsumptionType.electricity;

//   AnalyticsProvider({
//     required this.energyProvider,
//     required this.applianceProvider,
//   });

//   Future<void> loadData() async {
//     isLoading = true;
//     errorMessage = '';
//     notifyListeners();

//     try {
//       await energyProvider.fetchConsumptionData();
//       await applianceProvider.fetchAppliances();
//     } catch (e) {
//       errorMessage = 'Failed to load analytics data: $e';
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void setSelectedPeriod(String period) {
//     selectedPeriod = period;
//     notifyListeners();
//   }

//   void setSelectedType(ConsumptionType type) {
//     selectedType = type;
//     notifyListeners();
//   }
// }

// analytics_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/providers/energy_provider.dart';
import '../../models/energy_consumption_model.dart';

enum AnalyticsTab { overview, breakdown, trends }

class AnalyticsProvider with ChangeNotifier {
  bool isLoading = true;
  String errorMessage = '';
  String selectedPeriod = 'Monthly';
  ConsumptionType selectedType = ConsumptionType.electricity;
  late TabController tabController;

  void setSelectedPeriod(String period) {
    selectedPeriod = period;
    notifyListeners();
  }

  void setSelectedType(ConsumptionType type) {
    selectedType = type;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void resetError() {
    errorMessage = '';
    notifyListeners();
  }

  Future<void> initializeData(BuildContext context) async {
    setLoading(true);
    resetError();
    notifyListeners();

    try {
      await Provider.of<EnergyProvider>(context, listen: false)
          .fetchConsumptionData();
      await Provider.of<ApplianceProvider>(context, listen: false)
          .fetchAppliances();
    } catch (e) {
      setError('Failed to load analytics data: $e');
    }

    setLoading(false);
    notifyListeners();
  }
}
