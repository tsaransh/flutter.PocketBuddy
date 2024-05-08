import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> settingMenu = [
      'Profile',
      'Theme',
      'Invite a friend',
      'Logout',
      'App Update'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.separated(
          itemCount: settingMenu.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(color: Colors.grey), // Add dividers
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                if (index == 0) {}
                if (index == 1) {}
                if (index == 2) {}
                if (index == 3) {
                  FirebaseAuth.instance.signOut();
                }
              },
              leading: _getIconForSetting(settingMenu[index]), // Add icons
              title: Text(
                settingMenu[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            );
          },
        ),
      ),
    );
  }

  // Function to get icons for each setting
  Icon _getIconForSetting(String setting) {
    switch (setting) {
      case 'Profile':
        return const Icon(Icons.person);
      case 'Theme':
        return const Icon(Icons.palette);
      case 'Invite a friend':
        return const Icon(Icons.person_add);
      case 'Logout':
        return const Icon(Icons.logout);
      case 'App Update':
        return const Icon(Icons.system_update_alt);
      default:
        return const Icon(Icons.settings);
    }
  }
}
