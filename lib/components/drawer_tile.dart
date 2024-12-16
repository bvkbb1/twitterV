import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final Icon icon;
  final String label;
  final Function()? onTap;
  const MyDrawerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Theme.of(context).colorScheme.primary,
      iconColor: Theme.of(context).colorScheme.primary,
      leading: icon,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}