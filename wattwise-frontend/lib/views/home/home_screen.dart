import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/analytic_provider.dart';
import 'package:wattwise/providers/home_provider.dart';
import 'package:wattwise/views/analytics/analytics_screen.dart';
import 'package:wattwise/views/appliance/appliance_list_screen.dart';
import 'package:wattwise/views/appliance/meter_reading_screen.dart';
import 'package:wattwise/views/profile/profile_screen.dart';
import 'package:wattwise/views/settings/settings_screen.dart';
import 'package:wattwise/widgets/home/home_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeContent(),
      ApplianceListScreen(),
      MeterReadingScreen(),
      ChangeNotifierProvider(
        create: (_) => AnalyticsProvider(),
        child: const AnalyticsScreen(),
      ),
      ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadInitialData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(homeProvider.getTitle()),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: homeProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : homeProvider.errorMessage.isNotEmpty
                  ? Center(
                      child: ListView(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              homeProvider.errorMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () =>
                                homeProvider.loadInitialData(context),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : IndexedStack(
                      index: homeProvider.selectedIndex,
                      children: _screens,
                    ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: homeProvider.selectedIndex,
            onTap: homeProvider.onItemTapped,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.devices), label: 'Appliances'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.electric_meter), label: 'Readings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insights), label: 'Analytics'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
