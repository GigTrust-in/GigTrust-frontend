import 'package:flutter/material.dart';
import '../models/job.dart';
import '../data/sample_jobs.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _allJobs = [...sampleJobs];

  List<Job> get allJobs => [..._allJobs];

  List<Job> get ongoingJobs =>
      _allJobs.where((job) => job.status == 'Open' || job.status == 'Assigned').toList();

  List<Job> get pastJobs =>
      _allJobs.where((job) => job.status == 'Completed').toList();

  void addJob(Job job) {
    _allJobs.add(job);
    notifyListeners();
  }

  void completeJob(String jobId) {
    final index = _allJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(status: 'Completed');
      notifyListeners();
    }
  }

  List<Job> filterJobsByCategory(String category) {
    if (category == 'All') return allJobs;
    return _allJobs
        .where((job) =>
            (job.jobType ?? '').toLowerCase() == category.toLowerCase())
        .toList();
  }
}