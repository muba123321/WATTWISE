import 'package:flutter/material.dart';

import 'package:wattwise/views/auth/login_screen.dart';
import 'package:wattwise/views/auth/register_screen.dart';
import 'package:wattwise/widgets/custom/common_button.dart';

import '../../config/app_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: size.width * 0.6,
                  ),
                  const SizedBox(height: 24),
                  // You can add your optional SVG or any graphics here
                  FeaturesWidget(),
                  const SizedBox(height: 24),
                  CustomElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      label: 'Login',
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      borderRadius: 24),

                  const SizedBox(height: 16),
                  CustomElevatedButton(
                      label: 'Register',
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.primaryColor,
                      borderColor: theme.primaryColor,
                      borderRadius: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturesWidget extends StatelessWidget {
  const FeaturesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: theme.textTheme.headlineLarge,
          textAlign: TextAlign.right,
        ),
        Text(
          AppConstants.appDescription,
          style: theme.textTheme.labelMedium,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 24),
        Text(
          'Features',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(context, 'Track energy consumption', Icons.bolt),
        _buildFeatureItem(
            context, 'Manage household appliances', Icons.devices),
        _buildFeatureItem(
            context, 'Set energy-saving goals', Icons.emoji_events),
        _buildFeatureItem(
            context, 'Get personalized recommendations', Icons.lightbulb),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
