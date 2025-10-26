import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../utils/color_ext.dart';

class OngoingWorksScreen extends StatelessWidget {
  const OngoingWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashboardPath = user?.role == Role.worker
        ? '/worker-dashboard'
        : '/client-dashboard';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Works'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, dashboardPath),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // use the safe helper instead of deprecated withOpacity
                color: Colors.black.withOpacitySafe(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Text(
            'This page is under construction.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
