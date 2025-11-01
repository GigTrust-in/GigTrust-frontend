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
          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'ongoing_gigs', child: Text('Ongoing Gigs')),
        const PopupMenuItem(value: 'past_gigs', child: Text('Past Gigs')),
        const PopupMenuItem(value: 'find_jobs', child: Text('Find Jobs')),
        const PopupMenuItem(value: 'ongoing_txn', child: Text('Ongoing Transactions')),
        const PopupMenuItem(value: 'past_txn', child: Text('Past Transactions')),
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
          case 'ongoing_gigs':
            Navigator.pushNamed(context, '/ongoing-gigs');
            break;
          case 'past_gigs':
            Navigator.pushNamed(context, '/transactions'); // reuse if needed
            break;
          case 'find_jobs':
            Navigator.pushNamed(context, '/find-jobs');
            break;
          case 'ongoing_txn':
            Navigator.pushNamed(context, '/ongoing-transactions');
            break;
          case 'past_txn':
            Navigator.pushNamed(context, '/transactions-history');
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