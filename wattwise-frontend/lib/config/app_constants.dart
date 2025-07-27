class ApiConstants {
  // Base URL - Mobile device: Your server URL will need to be updated for mobile devices
  // static const String baseUrl =
  //     'http://192.168.19.95:8000/api'; // For Android Emulator
  static const String baseUrl = 'http://localhost:8000/api';
  // 'http://192.168.17.233:8000/api'; // For iOS Simulator
  // static const String baseUrl = 'https://your-app-name.replit.app/api'; // For production

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Appliance endpoints
  static const String appliances = '/appliances';
  static const String standardAppliances = '/appliances/standard/types';

  // Meter reading endpoints
  static const String meterReadings = '/readings';
  static const String consumption = '/consumption';

  // User endpoints
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userPreferences = '/user/preferences';
  static const String goals = '/user/goals';
  static const String tips = '/tips';
}

class AppConstants {
  static const String appName = 'Energy Monitor';
  static const String appDescription =
      'Monitor and control your energy consumption';
  static const String appVersion = '1.0.0';

  static const List<String> energySavingTips = [
    'Turn off lights when not in use',
    'Unplug electronics when not in use',
    'Use energy-efficient appliances',
    'Reduce standby power consumption',
    'Use natural lighting when possible',
    'Air dry clothes instead of using a dryer',
    'Adjust thermostat settings for optimal efficiency',
    'Regular maintenance of appliances ensures optimal efficiency',
    'Use a power strip to reduce phantom energy use',
    'Consider installing solar panels for renewable energy'
  ];
}
