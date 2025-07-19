import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/user_provider.dart';
import 'package:wattwise/views/home/home_screen.dart';

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final navigator = Navigator.of(context);

    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      final success = await userProvider.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success && context.mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setError('Invalid email or password.');
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final navigator = Navigator.of(context);

    setLoading(true);
    clearError();

    try {
      final success = await userProvider.loginWithGoogle();

      if (success && context.mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setError('Google login failed.');
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void reset() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = '';
    _isLoading = false;
    _obscurePassword = true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
// This provider manages the state for the login screen, including form inputs,
// loading state, password visibility, and error messages. It provides methods
// to toggle password visibility, set and clear error messages, and reset the
// form state. The `dispose` method ensures that the controllers are properly
// cleaned up when the provider is no longer needed.
// This allows for better separation of concerns and makes the login screen
// easier to manage and test. The provider can be used with a `ChangeNotifierProvider`
// in the widget tree to provide the login state to the UI components.
// This approach follows the Provider pattern in Flutter, allowing for reactive
// updates to the UI when the state changes. The `LoginProvider` can be accessed
// in the login screen using `Provider.of<LoginProvider>(context)` or by using
// `Consumer<LoginProvider>` or Selectors to rebuild parts of the UI when the state changes.
// This structure also makes it easier to implement features like form validation,
// error handling, and loading indicators in a clean and maintainable way.
