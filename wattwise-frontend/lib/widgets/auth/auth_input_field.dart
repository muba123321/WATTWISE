import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixTap;
  final IconData? suffixIcon;
  final TextInputAction? textInputAction;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.onSuffixTap,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
          ),
          prefixIcon:
              Icon(prefixIcon, color: Theme.of(context).colorScheme.primary),
          suffixIcon: onSuffixTap != null && suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon),
                  onPressed: onSuffixTap,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(24),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(24),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
        ));
  }
}
