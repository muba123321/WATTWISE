import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/profile_Provider.dart';
import 'package:wattwise/providers/user_provider.dart';

class EditprofileForm extends StatelessWidget {
  final ProfileProvider profile;
  const EditprofileForm({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: profile.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Profile image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    backgroundImage: profile.profileImage != null
                        ? FileImage(profile.profileImage!)
                        : (user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null),
                    child:
                        profile.profileImage == null && user?.photoUrl == null
                            ? Text(
                                user?.firstName != null &&
                                        user!.firstName!.isNotEmpty
                                    ? user.firstName![0].toUpperCase()
                                    : user!.email[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        color: Colors.white,
                        onPressed: profile.pickImage,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        iconSize: 20,
                        splashRadius: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Error message
            if (profile.errorMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile.errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Name field
            TextFormField(
              controller: profile.firstnameController,
              decoration: const InputDecoration(
                labelText: 'first Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your firstname';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: profile.lastnameController,
              decoration: const InputDecoration(
                labelText: 'last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your lastname';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email field (disabled)
            TextFormField(
              controller: profile.emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                helperText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      profile.setEditingProfile(false);
                      profile.profileImage = null;
                      if (user != null) {
                        profile.firstnameController.text = user.firstName ?? '';
                        profile.lastnameController.text = user.lastName ?? '';
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => profile.updateProfile(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
