import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wattwise/config/theme.dart';
import 'package:wattwise/firebase_options.dart';
import 'package:wattwise/providers/appliance_provider.dart';
import 'package:wattwise/providers/energy_provider.dart';
import 'package:wattwise/providers/home_provider.dart';
import 'package:wattwise/providers/profile_Provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:wattwise/views/splash/splash_screen.dart';

List<CameraDescription> cameras = [];
void main() async {
  // Ensure that the Flutter
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize camera
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    log('Error initializing camera: $e');
  }

  runApp(MyApp(
    storageService: storageService,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  const MyApp({
    super.key,
    required this.storageService,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(storageService)),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ApplianceProvider()),
        ChangeNotifierProvider(create: (_) => EnergyProvider()),
      ],
      child: Consumer<UserProvider>(builder: (context, userProvider, _) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Energy Monitor',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:
                userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen());
      }),
    );
  }
}

// lib/
// ├── main.dart
// ├── config/             # base_url, constants
// ├── models/             # User, Device
// ├── services/           # AuthService, DeviceService
// ├── views/              # Screens
// │   ├── auth/
// │   ├── home/
// │   ├── usage/
// ├── widgets/            # Reusable widgets
// ├── providers/          # State management
// └── utils/              # Helpers, formatters
