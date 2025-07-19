import 'package:flutter/material.dart';
import 'package:wattwise/providers/profile_Provider.dart';

class ErrorView extends StatelessWidget {
  final ProfileProvider profile;
  const ErrorView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              profile.errorMessage.isEmpty
                  ? 'Unable to load user profile.'
                  : profile.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => profile.loadProfile(context),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
