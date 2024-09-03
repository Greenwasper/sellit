import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {

  final bool value;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final IconData icon;
  final void Function(bool)? onChanged;

  const CustomSwitchTile({super.key, required this.value, this.title = '', this.subtitle = '', this.iconBackgroundColor = Colors.black, this.icon = Icons.notifications, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: CircleAvatar(
        backgroundColor: iconBackgroundColor,
        child: Icon(icon, size: 20, color: Colors.white),
      ), // Icon or widget to display before the title
    );
  }
}
