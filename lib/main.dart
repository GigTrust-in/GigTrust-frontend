import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/worker_dashboard.dart';
import 'screens/client_dashboard.dart';
import 'screens/profile_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ongoing_works_screen.dart';
import 'screens/worker_info_screen.dart';
import 'screens/client_info_screen.dart';
import 'screens/transactions_history_screen.dart';
import 'screens/ongoing_transactions_screen.dart';
import 'screens/ongoing_gigs_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GigTrust',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/worker-dashboard': (_) => const WorkerDashboard(),
        '/client-dashboard': (_) => const ClientDashboard(),
        '/profile': (_) => const ProfileScreen(),
        '/transactions': (_) => const TransactionsScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/ongoing-works': (_) => const OngoingWorksScreen(),
        '/worker-info': (_) => const WorkerInfoScreen(),
        '/client-info': (_) => const ClientInfoScreen(),
        '/transactions-history': (_) => const TransactionsHistoryScreen(),
        '/ongoing-transactions': (_) => const OngoingTransactionsScreen(),
        '/ongoing-gigs': (_) => const OngoingGigsScreen(),
      },
    );
  }
}
