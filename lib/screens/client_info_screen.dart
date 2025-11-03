import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/job.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';

class ClientInfoScreen extends StatelessWidget {
  const ClientInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Client Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Hello, ${user?.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Total Posted Gigs: 0', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final tempJob = Job(
                    id: 'job-sample-${index + 1}',
                    title: 'Client gig #${index + 1}',
                    description: 'Brief about this client gig #${index + 1}',
                    clientName:
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).user?.name ??
                        'Client',
                    postedDate: DateTime.now().toIso8601String().split('T')[0],
                    status: 'Open',
                    amount: '',
                    location: '',
                    tenure: '',
                    jobType: 'General',
                    minRating: '',
                    experience: '',
                    skills: '',
                  );

                  return JobCard(
                    title: tempJob.title,
                    description: tempJob.description,
                    onTap: () {},
                    job: tempJob, clientName: '',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
