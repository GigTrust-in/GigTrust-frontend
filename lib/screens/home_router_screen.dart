import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import 'worker_dashboard.dart';
import 'client_dashboard.dart';

class HomeRouterScreen extends StatelessWidget {
  const HomeRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return user.role == Role.worker
        ? const WorkerDashboard()
        : const ClientDashboard();
  }
}
