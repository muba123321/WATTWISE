// Refactored ProfileProvider.loadProfile() to avoid redundant user fetch
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class ProfileProvider with ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  File? profileImage;
  bool isEditingProfile = false;

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> loadProfile(BuildContext context) async {
    final provider = context.read<UserProvider>();

    if (provider.user != null) {
      firstnameController.text = provider.user?.firstName ?? '';
      lastnameController.text = provider.user?.lastName ?? '';
      emailController.text = provider.user?.email ?? '';
      return; // 🛑 Skip fetch if user already exists
    }

    setLoading(true);

    try {
      // await provider.fetchUserProfile(forceRefresh: false);
      final user = provider.user;
      if (user != null) {
        firstnameController.text = user.firstName ?? '';
        lastnameController.text = user.firstName ?? '';
        emailController.text = user.email;
      }
    } catch (e) {
      errorMessage = 'Failed to load profile: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }

  void setEditingProfile(bool value) {
    isEditingProfile = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    if (firstnameController.text.trim().isEmpty &&
        lastnameController.text.trim().isEmpty) {
      errorMessage = 'Please enter your firstName';
      notifyListeners();
      return;
    }

    setLoading(true);

    try {
      await Provider.of<UserProvider>(context, listen: false).updateProfile(
        firstName: firstnameController.text,
        lastName: lastnameController.text,
        profileImage: profileImage,
      );
    } catch (e) {
      errorMessage = 'Failed to update profile: ${e.toString()}';
    } finally {
      setLoading(false);
    }
  }

  // Future<bool> logout(BuildContext context) async {
  //   _setLoading(true);
  //   log('it is logging out ,...');
  //   try {
  //     log('it is logging out started,...');
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     final status = await userProvider.logout();
  //     // log('Logout status: $status');
  //     // log('it is logging out continueing and status is : $status,...');
  //     // if (status == true && context.mounted) {
  //     //   log('it is logging out context is mounted and status is : $status,...');

  //     //   Navigator.of(context).pushReplacement(
  //     //     MaterialPageRoute(builder: (_) => const SplashScreen()),
  //     //   );
  //     //   log('it is logging out context is mounted and status is...');
  //     //   _setLoading(false);
  //     //   log('set loading is false..... $isLoading');
  //     // }

  //     return status;
  //   } catch (e) {
  //     errorMessage = 'Failed to logout: ${e.toString()}';
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  void clearError() {
    errorMessage = '';
    notifyListeners();
  }

  void setLoading(bool value) {
    if (isLoading != value) {
      isLoading = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
