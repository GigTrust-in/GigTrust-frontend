import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _skillsController;
  late TextEditingController _passwordController;
  String _selectedGender = 'Other';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _skillsController = TextEditingController(text: user?.skills ?? '');
    _passwordController = TextEditingController();
    _selectedGender = user?.gender ?? 'Other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillsController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.updateProfile(
      name: _nameController.text,
      gender: _selectedGender,
      skills: _skillsController.text,
      newPassword:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedGender = v);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _skillsController,
                  decoration:
                      const InputDecoration(labelText: 'Skills (e.g., Plumbing)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}