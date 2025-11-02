// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../models/role.dart';
// import '../utils/color_ext.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   Role selectedRole = Role.worker;
//   String error = '';

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthProvider>(context, listen: false);

//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacitySafe(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 const Icon(Icons.work_outline, size: 64, color: Colors.blue),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Welcome Back to GigTrust',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text('Sign in to continue your journey.'),
//                 const SizedBox(height: 24),
//                 TextField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(labelText: 'Email'),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(labelText: 'Password'),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ChoiceChip(
//                       label: const Text('Worker'),
//                       selected: selectedRole == Role.worker,
//                       onSelected: (_) =>
//                           setState(() => selectedRole = Role.worker),
//                     ),
//                     const SizedBox(width: 8),
//                     ChoiceChip(
//                       label: const Text('Client'),
//                       selected: selectedRole == Role.client,
//                       onSelected: (_) =>
//                           setState(() => selectedRole = Role.client),
//                     ),
//                   ],
//                 ),
//                 if (error.isNotEmpty) ...[
//                   const SizedBox(height: 8),
//                   Text(error, style: const TextStyle(color: Colors.red)),
//                 ],
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_emailController.text.isEmpty ||
//                         _passwordController.text.isEmpty) {
//                       setState(() => error = 'Please fill in all fields.');
//                       return;
//                     }
//                     auth.login(_emailController.text, selectedRole);
//                     Navigator.pushReplacementNamed(
//                       context,
//                       selectedRole == Role.worker
//                           ? '/worker-dashboard'
//                           : '/client-dashboard',
//                     );
//                   },
//                   child: const Text('Sign In'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pushNamed(context, '/register'),
//                   child: const Text('Don\'t have an account? Sign up'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../utils/validators.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Role selectedRole = Role.worker;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Gradient colors for a professional, light blue background
    const Color topColor = Color(0xFFE3F0FF); // very light blue
    const Color bottomColor = Color(0xFFB6D0F9); // slightly deeper blue

    return Scaffold(
      // Remove default background, make body fill the screen
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              topColor,
              bottomColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.95 * 255).round()),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withAlpha((0.08 * 255).round()),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.withAlpha((0.12 * 255).round()),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7FBFF4), Color(0xFF3869B9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Text('G', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('GigTrust', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF204C74))),
                          SizedBox(height: 4),
                          Text('Trusted gigs, trusted workers', style: TextStyle(fontSize: 14, color: Color(0xFF3869B9))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.blue[50]?.withAlpha((0.7 * 255).round()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.blue[50]?.withAlpha((0.7 * 255).round()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Worker'),
                        selected: selectedRole == Role.worker,
                        selectedColor: Colors.blue[200],
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(
                          color: selectedRole == Role.worker
                              ? Colors.blue[900]
                              : Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setState(() => selectedRole = Role.worker),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Client'),
                        selected: selectedRole == Role.client,
                        selectedColor: Colors.blue[200],
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(
                          color: selectedRole == Role.client
                              ? Colors.blue[900]
                              : Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setState(() => selectedRole = Role.client),
                      ),
                    ],
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3869B9),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white, // Make the text white
                        ),
                      ),
                      onPressed: () {
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          setState(() => error = 'Please fill in all fields.');
                          return;
                        }

                        // Basic validation
                        if (!isValidEmail(_emailController.text.trim())) {
                          setState(() => error = 'Please enter a valid email (include @ and domain).');
                          return;
                        }
                        if (!isValidPassword(_passwordController.text)) {
                          setState(() => error = 'Password must be 8+ chars, include a number and a special character.');
                          return;
                        }

                        final success = auth.login(_emailController.text.trim(), _passwordController.text, selectedRole);
                        if (!success) {
                          setState(() => error = 'Invalid credentials or no such user. Please register.');
                          return;
                        }

                        Navigator.pushReplacementNamed(
                          context,
                          selectedRole == Role.worker
                              ? '/worker-dashboard'
                              : '/client-dashboard',
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white), // Explicitly set text color to white
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Don\'t have an account? Sign up',
                      style: TextStyle(
                        color: Color.fromARGB(138, 1, 8, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}