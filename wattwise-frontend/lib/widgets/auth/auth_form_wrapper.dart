import 'package:flutter/material.dart';

class AuthFormWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthFormWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: theme.textTheme.headlineLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle,
            style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        child,
      ],
    );
  }
}
