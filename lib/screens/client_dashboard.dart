import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import '../widgets/top_profile_menu.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final List<Map<String, String>> _postedGigs = [];

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _showAddGigDialog(String ownerEmail) {
    _titleController.clear();
    _descController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post New Gig'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final desc = _descController.text.trim();
              if (title.isEmpty || desc.isEmpty) return;
              setState(() {
                _postedGigs.insert(0, {
                  'title': title,
                  'description': desc,
                  'owner': ownerEmail,
                });
              });
              Navigator.of(context).pop();
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // Seed one sample gig for the current user on first build (non-invasive).
    if (user != null &&
        _postedGigs.where((g) => g['owner'] == user.email).isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _postedGigs.insertAll(0, [
              {
                'title': 'My First Gig',
                'description': 'A sample gig posted by you. Edit or add more.',
                'owner': user.email,
              },
            ]);
          });
        }
      });
    }

    final myGigs = user == null
        ? <Map<String, String>>[]
        : _postedGigs.where((g) => g['owner'] == user.email).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user != null ? 'Client Dashboard — ${user.name}' : 'Client Dashboard',
        ),
        leading: const TopProfileMenu(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No user signed in.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              )
            : myGigs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You have no active posted gigs.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _showAddGigDialog(user.email),
                      child: const Text('Post Your First Gig'),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width < 768
                      ? 1
                      : (width < 1024 ? 2 : 3);
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: myGigs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final job = myGigs[index];
                      return JobCard(
                        title: job['title'] ?? 'Untitled',
                        description: job['description'] ?? '',
                        onTap: () {
                          // optional: open details or edit flow
                        },
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddGigDialog(user.email),
              icon: const Icon(Icons.add),
              label: const Text('Post Gig'),
            ),
    );
  }
}
