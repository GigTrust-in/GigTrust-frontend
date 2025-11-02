import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../utils/validators.dart';
import '../utils/color_ext.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  Role? selectedRole;
  String error = '';
  bool otpSent = false; 

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacitySafe(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text('Create your GigTrust Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Join a community of talent and opportunity.'),
                const SizedBox(height: 24),

                // --- Name ---
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),

                // --- Email ---
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),

                // --- Password ---
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),

                // --- Phone with Send OTP Button ---
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        if (_phoneController.text.isEmpty) {
                          setState(() => error = 'Please enter phone number first.');
                          return;
                        }
                        setState(() {
                          otpSent = true;
                          error = '';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP sent successfully')),
                        );
                      },
                      child: const Text('Send OTP'),
                    ),
                  ],
                ),

                // --- OTP Field (only show after OTP sent) ---
                if (otpSent) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                  ),
                ],

                const SizedBox(height: 12),

                // --- Role Selection ---
                DropdownButton<Role>(
                  value: selectedRole,
                  hint: const Text('Select a role'),
                  items: const [
                    DropdownMenuItem(value: Role.worker, child: Text('Worker')),
                    DropdownMenuItem(value: Role.client, child: Text('Client')),
                  ],
                  onChanged: (role) => setState(() => selectedRole = role),
                  isExpanded: true,
                ),

                // --- Error Text ---
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(error, style: const TextStyle(color: Colors.red)),
                ],

                const SizedBox(height: 16),

                // --- Create Account Button ---
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _otpController.text.isEmpty ||
                        selectedRole == null) {
                      setState(() => error = 'Please fill in all fields.');
                      return;
                    }

                    // Validate email and password
                    if (!isValidEmail(_emailController.text.trim())) {
                      setState(() => error = 'Please enter a valid email (include @ and domain).');
                      return;
                    }
                    if (!isValidPassword(_passwordController.text)) {
                      setState(() => error = 'Password must be 8+ chars, include a number and a special character.');
                      return;
                    }

                    // Placeholder for verifying OTP
                    // Normally, you’d verify the OTP here before continuing

                    auth.register(_nameController.text, _emailController.text.trim(), selectedRole!, _passwordController.text);
                    Navigator.pushReplacementNamed(
                      context,
                      selectedRole == Role.worker
                          ? '/worker-dashboard'
                          : '/client-dashboard',
                    );
                  },
                  child: const Text('Create Account'),
                ),

                // --- Already have account ---
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}