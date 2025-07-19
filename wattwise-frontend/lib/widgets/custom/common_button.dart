import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final Color? borderColor;
  final double borderRadius;
  final Widget? icon;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 50,
    this.borderRadius = 12,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, height),
        backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
        foregroundColor: foregroundColor ?? Colors.white,
        side: BorderSide(
          color: borderColor ?? Colors.transparent, // 👈 Outline border
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    );
  }
}
