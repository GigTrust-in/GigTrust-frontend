import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/worker_dashboard.dart';
import 'screens/client_dashboard.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/find_jobs_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/ongoing_gigs_screen.dart';
import 'screens/transactions_history_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/support_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/worker-dashboard': (_) => const WorkerDashboard(),
        '/client-dashboard': (_) => const ClientDashboard(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/about': (_) => const AboutUsScreen(),
        '/find-jobs': (_) => const FindJobsScreen(),
        '/transactions': (_) => const TransactionsScreen(),
        '/ongoing-gigs': (_) => const OngoingGigsScreen(),
        '/transactions-history': (_) => const TransactionsHistoryScreen(),
        '/feedback': (_) => const FeedbackScreen(),
        '/notifications': (_) => const NotificationScreen(),
        '/wallet': (_) => const WalletScreen(),
        '/support': (_) => const SupportScreen(),
      },
    );
  }
}