import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wattwise/providers/login_provider.dart';
import 'package:wattwise/views/auth/register_screen.dart';
import 'package:wattwise/widgets/auth/auth_input_field.dart';
import 'package:wattwise/widgets/auth/auth_message_box.dart';
import 'package:wattwise/widgets/auth/auth_form_wrapper.dart';
import 'package:wattwise/widgets/custom/common_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: const LoginScreenBody(),
    );
  }
}

class LoginScreenBody extends StatelessWidget {
  const LoginScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false, // ← prevents back navigation
      child: Scaffold(
        appBar: AppBar(
            leading: const SizedBox.shrink(), title: const Text('Login')),
        body: Consumer<LoginProvider>(
          builder: (context, provider, _) {
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
                                  title: 'Welcome Back',
                                  subtitle:
                                      'Login to continue monitoring your energy usage',
                                  child: Column(
                                    children: [
                                      if (provider.errorMessage.isNotEmpty)
                                        AuthMessageBox.error(
                                            provider.errorMessage),
                                      AuthTextField(
                                        controller: provider.emailController,
                                        label: 'Email',
                                        prefixIcon: Icons.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) => value!.isEmpty
                                            ? 'Please enter your email'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      Selector<LoginProvider, bool>(
                                          selector: (_, p) => p.obscurePassword,
                                          builder: (_, isObscured, __) {
                                            return AuthTextField(
                                              controller:
                                                  provider.passwordController,
                                              label: 'Password',
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              textInputAction:
                                                  TextInputAction.done,
                                              prefixIcon: Icons.lock,
                                              obscureText: isObscured,
                                              suffixIcon: isObscured
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              onSuffixTap: () => provider
                                                  .togglePasswordVisibility(),
                                              validator: (value) => value!
                                                      .isEmpty
                                                  ? 'Please enter your password'
                                                  : null,
                                            );
                                          }),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // TODO: Forgot password screen
                                          },
                                          child: const Text('Forgot Password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      CustomElevatedButton(
                                        label: 'Login',
                                        onPressed: () =>
                                            provider.login(context),
                                        backgroundColor:
                                            theme.colorScheme.onPrimary,
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                        borderColor: theme.colorScheme.primary,
                                        borderRadius: 24,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDivider(context),
                                      const SizedBox(height: 16),
                                      CustomElevatedButton(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        borderRadius: 24,
                                        icon: FaIcon(FontAwesomeIcons.google,
                                            size: 18,
                                            color: theme.colorScheme.error),
                                        label: 'Continue with Google',
                                        onPressed: () =>
                                            provider.loginWithGoogle(context),
                                      ),
                                      const SizedBox(height: 32),
                                      _buildBottomLink(
                                        context,
                                        'Don\'t have an account? ',
                                        'Register',
                                        () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const RegisterScreen()),
                                          );
                                        },
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
          },
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: theme.textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildBottomLink(
      BuildContext context, String text, String linkText, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: theme.textTheme.bodyMedium),
        TextButton(onPressed: onTap, child: Text(linkText)),
      ],
    );
  }
}
