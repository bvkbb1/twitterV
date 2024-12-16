import 'package:flutter/material.dart';

class MySettingsTile extends StatelessWidget {
  final String leading;
  final Widget action;
  const MySettingsTile({
    super.key,
    required this.leading,
    required this.action,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10)
      ),
      margin: const EdgeInsets.only(left: 12, top: 8, right: 12),
      child: ListTile(
        textColor: Theme.of(context).colorScheme.primary,
        iconColor: Theme.of(context).colorScheme.primary,
        leading: Text(leading, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        trailing: action,
      ),
    );
  }
}