import '../models/job.dart';

final List<Job> sampleJobs = [
  Job(
    id: 'job-1',
    title: 'Mobile App Development',
    description: 'Build a Flutter app for e-commerce.',
    clientName: 'Alice',
    postedDate: '2025-10-25',
    status: 'Open',
  ),
  Job(
    id: 'job-2',
    title: 'Website Design',
    description: 'Design a responsive website using React.',
    clientName: 'Bob',
    postedDate: '2025-10-24',
    status: 'Open',
  ),
  Job(
    id: 'job-3',
    title: 'Data Analysis',
    description: 'Analyze sales data using Python.',
    clientName: 'Charlie',
    postedDate: '2025-10-23',
    status: 'Assigned',
    workerName: 'Worker1',
  ),
];