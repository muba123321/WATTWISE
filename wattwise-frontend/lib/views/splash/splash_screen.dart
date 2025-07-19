import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/views/home/home_screen.dart';
import 'package:wattwise/views/auth/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeController);

    _fadeController.forward();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final isLoggedIn = await userProvider.tryAutoLogin();

      await Future.delayed(const Duration(milliseconds: 1200)); // smooth feel

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Fallback if something goes wrong
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final splashImage = isDarkMode
        ? 'assets/images/wattwise_dark.png'
        : 'assets/images/wattwise_light.png';
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(splashImage),
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'WattWise',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Loading...',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
