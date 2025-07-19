import 'package:flutter/material.dart';

class AuthMessageBox extends StatelessWidget {
  final String message;
  final MaterialColor color;

  const AuthMessageBox.error(this.message, {super.key}) : color = Colors.red;
  const AuthMessageBox.success(this.message, {super.key})
      : color = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: color[900],
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
