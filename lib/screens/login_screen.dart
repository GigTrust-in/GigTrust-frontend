import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color_ext.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // same as register
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacitySafe(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo + Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFF3A79D1),
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GigTrust',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF204C74),
                          ),
                        ),
                        Text(
                          'Trusted gigs, trusted workers',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- Email ---
                _buildCurvedTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // --- Password ---
                _buildCurvedTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 18),

                // --- Role Selection ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Worker'),
                      selected: selectedRole == Role.worker,
                      selectedColor: const Color(0xFFBFD7F9),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: selectedRole == Role.worker
                            ? Colors.blue[900]
                            : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          setState(() => selectedRole = Role.worker),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Client'),
                      selected: selectedRole == Role.client,
                      selectedColor: const Color(0xFFBFD7F9),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: selectedRole == Role.client
                            ? Colors.blue[900]
                            : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          setState(() => selectedRole = Role.client),
                    ),
                  ],
                ),

                // --- Error Message ---
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 12),
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

                // --- Sign In Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A79D1),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        setState(() => error = 'Please fill in all fields.');
                        return;
                      }

                      if (!isValidEmail(_emailController.text.trim())) {
                        setState(() =>
                            error = 'Please enter a valid email address.');
                        return;
                      }

                      if (!isValidPassword(_passwordController.text)) {
                        setState(() => error =
                            'Password must be 8+ chars, include a number and a special character.');
                        return;
                      }

                      final success = auth.login(
                        _emailController.text.trim(),
                        _passwordController.text,
                        selectedRole,
                      );

                      if (!success) {
                        setState(() => error =
                            'Invalid credentials or user not found. Please register.');
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // --- Register Redirect ---
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(
                      color: Color(0xFF204C74),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// --- Curved TextField Builder ---
  Widget _buildCurvedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacitySafe(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}