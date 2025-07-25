import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../config/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  final _currencyController = TextEditingController();
  final List<String> _energyUnits = ['kWh', 'MJ', 'BTU'];
  final List<String> _notificationTypes = [
    'Usage Alerts',
    'Bill Reminders',
    'Goal Updates',
    'Energy Tips',
    'System Updates'
  ];

  Map<String, bool> _selectedNotificationTypes = {};

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _initializeSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      await userProvider.fetchUserProfile();
    }

    final currentUser = userProvider.user;
    if (currentUser != null) {
      _currencyController.text = currentUser.preferences.currency ?? '\$';

      // Initialize notification types
      _selectedNotificationTypes = {};
      if (currentUser.preferences.notificationTypes != null) {
        for (final type in _notificationTypes) {
          _selectedNotificationTypes[type] =
              currentUser.preferences.notificationTypes!.contains(type);
        }
      } else {
        for (final type in _notificationTypes) {
          _selectedNotificationTypes[type] = true;
        }
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        throw Exception('User not found');
      }

      // Get the selected notification types
      final List<String> selectedTypes = _selectedNotificationTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Create updated preferences
      final updatedPreferences = user.preferences.copyWith(
        currency:
            _currencyController.text.isEmpty ? '\$' : _currencyController.text,
        energyUnit: _energyUnits.contains(user.preferences.energyUnit)
            ? user.preferences.energyUnit
            : _energyUnits.first,
        notificationTypes: selectedTypes,
      );

      await userProvider.updateUserPreferences(updatedPreferences);

      setState(() {
        _successMessage = 'Settings updated successfully';
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to save settings: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('User not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Success message
                      if (_successMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _successMessage,
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Theme settings
                      _buildSettingsSection(
                        'Theme Settings',
                        [
                          // Dark mode toggle
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle:
                                const Text('Enable dark theme for the app'),
                            value: user.preferences.isDarkMode,
                            onChanged: (value) async {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final updatedPreferences =
                                    user.preferences.copyWith(
                                  isDarkMode: value,
                                );

                                await userProvider
                                    .updateUserPreferences(updatedPreferences);
                              } catch (error) {
                                setState(() {
                                  _errorMessage =
                                      'Failed to update theme: ${error.toString()}';
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      // Measurement units
                      _buildSettingsSection(
                        'Measurement Units',
                        [
                          // Currency input
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: TextField(
                              controller: _currencyController,
                              decoration: InputDecoration(
                                labelText: 'Currency Symbol',
                                hintText: 'e.g. €, £',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),

                          // Energy unit picker
                          ListTile(
                            title: const Text('Energy Unit'),
                            subtitle: Text(user.preferences.energyUnit),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _showEnergyUnitPicker(
                                user.preferences.energyUnit),
                          ),
                        ],
                      ),

                      // Notification settings
                      _buildSettingsSection(
                        'Notification Settings',
                        [
                          // Enable notifications toggle
                          SwitchListTile(
                            title: const Text('Enable Notifications'),
                            subtitle: const Text(
                                'Receive notifications about energy usage and tips'),
                            value: user.preferences.notificationsEnabled,
                            onChanged: (value) async {
                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final updatedPreferences =
                                    user.preferences.copyWith(
                                  notificationsEnabled: value,
                                );

                                await userProvider
                                    .updateUserPreferences(updatedPreferences);
                              } catch (error) {
                                setState(() {
                                  _errorMessage =
                                      'Failed to update notifications: ${error.toString()}';
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                          ),

                          if (user.preferences.notificationsEnabled) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                'Notification Types',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ..._notificationTypes.map((type) {
                              return CheckboxListTile(
                                title: Text(type),
                                value: _selectedNotificationTypes[type] ?? true,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedNotificationTypes[type] =
                                        value ?? false;
                                  });
                                },
                              );
                            }),
                          ],
                        ],
                      ),

                      // Account settings
                      _buildSettingsSection(
                        'Account Settings',
                        [
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('Change Password'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Navigate to change password screen
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text('Verify Email'),
                            subtitle: Text(user.isEmailVerified
                                ? 'Email verified'
                                : 'Email not verified'),
                            trailing: user.isEmailVerified
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: user.isEmailVerified
                                ? null
                                : () {
                                    // Send email verification
                                  },
                          ),
                        ],
                      ),

                      // About section
                      _buildSettingsSection(
                        'About',
                        [
                          ListTile(
                            leading: const Icon(Icons.info),
                            title: Text('Version ${AppConstants.appVersion}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.policy),
                            title: const Text('Privacy Policy'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Open privacy policy
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.description),
                            title: const Text('Terms of Service'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Open terms of service
                            },
                          ),
                        ],
                      ),

                      // Save button
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Save Settings'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Future<void> _showEnergyUnitPicker(String currentUnit) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    String? selectedUnit = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Energy Unit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _energyUnits.map((unit) {
                return RadioListTile<String>(
                  title: Text(unit),
                  value: unit,
                  groupValue: currentUnit,
                  onChanged: (value) {
                    Navigator.of(context).pop(value);
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selectedUnit != currentUnit) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedPreferences = user.preferences.copyWith(
          energyUnit: selectedUnit,
        );

        await userProvider.updateUserPreferences(updatedPreferences);
      } catch (error) {
        setState(() {
          _errorMessage = 'Failed to update energy unit: ${error.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
