import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wattwise/providers/registration_provider.dart';
import 'package:wattwise/views/auth/login_screen.dart';
import 'package:wattwise/widgets/auth/auth_input_field.dart';
import 'package:wattwise/widgets/auth/auth_message_box.dart';
import 'package:wattwise/widgets/auth/auth_form_wrapper.dart';
import 'package:wattwise/widgets/custom/common_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: const RegisterScreenBody(),
    );
  }
}

class RegisterScreenBody extends StatelessWidget {
  const RegisterScreenBody({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar:
              AppBar(leading: SizedBox.shrink(), title: const Text('Register')),
          body: Consumer<RegisterProvider>(builder: (context, provider, _) {
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        IntrinsicHeight(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height -
                                  MediaQuery.of(context).padding.top -
                                  kToolbarHeight,
                            ),
                            child: Center(
                              child: Form(
                                key: provider.formKey,
                                child: AuthFormWrapper(
                                  title: 'Create Account',
                                  subtitle:
                                      'Join us to start monitoring your energy consumption',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (provider.errorMessage.isNotEmpty)
                                        AuthMessageBox.error(
                                            provider.errorMessage),
                                      AuthTextField(
                                        controller:
                                            provider.firstNameController,
                                        label: 'First Name',
                                        textInputAction: TextInputAction.next,
                                        prefixIcon: Icons.person,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your first name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AuthTextField(
                                        controller: provider.lastNameController,
                                        label: 'Last Name',
                                        textInputAction: TextInputAction.next,
                                        prefixIcon: Icons.person,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your last name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      AuthTextField(
                                        controller: provider.emailController,
                                        label: 'Email',
                                        textInputAction: TextInputAction.next,
                                        prefixIcon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Selector<RegisterProvider, bool>(
                                          selector: (_, p) => p.obscurePassword,
                                          builder: (_, isObscured, __) {
                                            return AuthTextField(
                                              controller:
                                                  provider.passwordController,
                                              label: 'Password',
                                              textInputAction:
                                                  TextInputAction.next,
                                              prefixIcon: Icons.lock,
                                              obscureText: isObscured,
                                              suffixIcon: isObscured
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              onSuffixTap: provider
                                                  .toggleObscurePassword,
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              validator:
                                                  provider.validatePassword,
                                            );
                                          }),
                                      const SizedBox(height: 16),
                                      Selector<RegisterProvider, bool>(
                                          selector: (_, p) =>
                                              p.obscureConfirmPassword,
                                          builder: (_, isObscured, __) {
                                            return AuthTextField(
                                              controller: provider
                                                  .confirmPasswordController,
                                              label: 'Confirm Password',
                                              textInputAction:
                                                  TextInputAction.done,
                                              prefixIcon: Icons.lock_outline,
                                              obscureText: isObscured,
                                              suffixIcon: isObscured
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              onSuffixTap: provider
                                                  .toggleObscureConfirmPassword,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please confirm your password';
                                                }
                                                if (value !=
                                                    provider.passwordController
                                                        .text) {
                                                  return 'Passwords do not match';
                                                }
                                                return null;
                                              },
                                            );
                                          }),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'By registering, you agree to our Terms of Service and Privacy Policy.',
                                              style: theme.textTheme.bodySmall,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      CustomElevatedButton(
                                        label: "Register",
                                        onPressed: () =>
                                            provider.register(context),
                                        backgroundColor:
                                            theme.colorScheme.onPrimary,
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                        borderColor: theme.colorScheme.primary,
                                        borderRadius: 24,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Expanded(child: Divider()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              'OR',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                          const Expanded(child: Divider()),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      CustomElevatedButton(
                                        label: 'Continue with Google',
                                        onPressed: () => provider
                                            .registerWithGoogle(context),
                                        icon: FaIcon(
                                          FontAwesomeIcons.google,
                                          size: 18,
                                          color: theme.colorScheme.error,
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        borderRadius: 24,
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const LoginScreen()),
                                              );
                                            },
                                            child: const Text('Login'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
          }),
        ));
  }
}
