import 'package:flutter/material.dart';

class InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const InfoItem(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ),
    );
  }
}
