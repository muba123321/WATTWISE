import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/views/home/home_screen.dart';

class RegisterProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String errorMessage = '';

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    if (!hasUppercase || !hasNumber) {
      return 'Include uppercase and number for a strong password';
    }
    return null;
  }

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Replace with actual backend call
      final success =
          await Provider.of<UserProvider>(context, listen: false).register(
        firstNameController.text,
        lastNameController.text,
        emailController.text,
        passwordController.text,
      );
      if (success && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Authentication failed';
      log('Registration failed: $errorMessage');
    } catch (e) {
      errorMessage = 'Registration failed. Try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithGoogle(BuildContext context) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final success = await Provider.of<UserProvider>(context, listen: false)
          .loginWithGoogle();

      if (success && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        errorMessage = 'Google sign-in failed.';
      }
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
