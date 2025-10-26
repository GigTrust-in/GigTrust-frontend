import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';

class OngoingGigsScreen extends StatelessWidget {
  const OngoingGigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final sample = List.generate(
      5,
      (i) => {
        'title': 'Ongoing Gig ${i + 1}',
        'description': 'Working on task ${i + 1}',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ongoing Gigs')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: user == null
            ? const Center(child: Text('Please login to see ongoing gigs.'))
            : ListView.builder(
                itemCount: sample.length,
                itemBuilder: (context, index) {
                  final g = sample[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: JobCard(
                      title: g['title']!,
                      description: g['description']!,
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
    );
  }
}
