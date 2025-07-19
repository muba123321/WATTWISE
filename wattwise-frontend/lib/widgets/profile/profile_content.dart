import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/providers/energy_provider.dart';
import 'package:wattwise/providers/home_provider.dart';
import 'package:wattwise/providers/profile_Provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/views/splash/splash_screen.dart';
import 'package:wattwise/widgets/meter/reading_type_selector.dart';
import 'package:wattwise/widgets/profile/goal_card.dart';
import 'package:wattwise/widgets/profile/info_item.dart';

class ProfileContent extends StatelessWidget {
  final User user;
  final EnergyProvider energyProvider;
  final ProfileProvider profile;
  final HomeProvider homeProvider;
  const ProfileContent(
      {super.key,
      required this.user,
      required this.energyProvider,
      required this.profile,
      required this.homeProvider});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return RefreshIndicator(
      onRefresh: () => profile.loadProfile(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.getInitials(),

                              // (user.firstName?.isNotEmpty == true
                              //     ? user.firstName!.toUpperCase()
                              //     : user.email.toUpperCase()),

                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // User name
                    Text(
                      user.firstName?.capitalize() ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Text(
                    //   user.lastName ?? 'User',
                    //   style: Theme.of(context).textTheme.headlineMedium,
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(height: 4),

                    // Email
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (!user.isEmailVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            try {
                              await userProvider.sendVerificationEmail();
                              // Show dialog/snackbar
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Verification Sent"),
                                  content: const Text(
                                      "A verification email has been sent. Please verify your email and log in again."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close dialog

                                        // Trigger logout and redirect
                                        profile.setLoading(true);
                                        userProvider.logout().then((status) {
                                          profile.setLoading(false);
                                          if (context.mounted) {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const SplashScreen()),
                                              (route) => false,
                                            );
                                          }

                                          homeProvider.onItemTapped(0);
                                        });
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Failed to send verification email. Try again.")),
                              );
                            }
                          },
                          icon: const Icon(Icons.verified_user),
                          label: const Text("Verify Email"),
                        ),
                      ),

                    // Edit profile button
                    OutlinedButton.icon(
                      onPressed: () => profile.setEditingProfile(true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Account information
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  InfoItem(
                    label: 'Member Since',
                    value: dateFormat.format(user.createdAt),
                    icon: Icons.calendar_today,
                  ),
                  const Divider(height: 1),
                  // InfoItem(
                  //   label: 'Last Login',
                  //   value: user.lastLogin != null
                  //       ? dateFormat.format(user.lastLogin!)
                  //       : 'N/A',
                  //   icon: Icons.access_time,
                  // ),
                  const Divider(height: 1),
                  InfoItem(
                    label: 'Email Verified',
                    value: user.isEmailVerified ? 'Yes' : 'No',
                    icon: Icons.verified,
                    valueColor:
                        user.isEmailVerified ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Energy goals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Energy Goals',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to add goal screen
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (user.goals != null && user.goals!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.goals!.length,
                itemBuilder: (context, index) {
                  return GoalCard(goal: user.goals![index]);
                },
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Energy Goals Set',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set energy-saving goals to track your progress and reduce consumption.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: !profile.isLoading
                    ? () async {
                        // Handle logout logic here
                        profile.setLoading(true);
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final status = await userProvider.logout();
                        if (status == true) {
                          Future.microtask(() {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const SplashScreen()),
                              (route) => false,
                            );
                            homeProvider.onItemTapped(0);
                          });
                        }
                        profile.setLoading(false);
                      }
                    : () {}, // Prevent multiple presses
                icon: const Icon(Icons.logout),
                label: Text(!profile.isLoading ? 'Logout' : 'Processing'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
