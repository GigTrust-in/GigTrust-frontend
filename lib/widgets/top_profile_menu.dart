import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

enum ProfileMenuAction { profile, settings, toggleTheme, logout }

class TopProfileMenu extends StatelessWidget {
  const TopProfileMenu({super.key});

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final user = auth.user;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: PopupMenuButton<ProfileMenuAction>(
        tooltip: 'Account',
        onSelected: (action) {
          switch (action) {
            case ProfileMenuAction.profile:
              Navigator.pushNamed(context, '/profile');
              break;
            case ProfileMenuAction.settings:
              Navigator.pushNamed(context, '/settings');
              break;
            case ProfileMenuAction.toggleTheme:
              theme.toggleTheme();
              break;
            case ProfileMenuAction.logout:
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ProfileMenuAction.profile,
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
            ),
          ),
          PopupMenuItem(
            value: ProfileMenuAction.settings,
            child: const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ),
          PopupMenuItem(
            value: ProfileMenuAction.toggleTheme,
            child: ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Toggle Dark Mode'),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: ProfileMenuAction.logout,
            child: const ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ),
        ],
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            user != null ? _initials(user.name) : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
