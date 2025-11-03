// lib/widgets/top_profile_menu.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TopProfileMenu extends StatelessWidget {
  const TopProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return PopupMenuButton<String>(
      iconSize: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 48),
      tooltip: 'Account menu',
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          (user != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'transactions', child: Text('Transactions')),
        const PopupMenuItem(value: 'wallet', child: Text('Wallet')),
        const PopupMenuItem(value: 'notifications', child: Text('Notifications')),
        const PopupMenuItem(value: 'support', child: Text('Support')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Logout'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'transactions':
            Navigator.pushNamed(context, '/transactions-history');
            break;
          case 'wallet':
            Navigator.pushNamed(context, '/wallet');
            break;
          case 'notifications':
            Navigator.pushNamed(context, '/notifications');
            break;
          case 'support':
            Navigator.pushNamed(context, '/support');
            break;
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            auth.logout();
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      },
    );
  }
}