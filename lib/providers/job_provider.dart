// lib/providers/job_provider.dart
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../data/sample_jobs.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _allJobs = [...sampleJobs];
  final Map<String, Set<String>> _rejectedByWorker = {};
  final Map<String, String> _escrowTx = {};

  List<Job> get allJobs => [..._allJobs];

  List<Job> get ongoingJobs =>
      _allJobs.where((job) => job.status == 'Open' || job.status == 'Assigned').toList();

  List<Job> get pastJobs => _allJobs.where((job) => job.status == 'Completed').toList();


  void addJob(Job job) {
    _allJobs.insert(0, job);
    notifyListeners();
  }

  void updateJob(Job updatedJob) {
    final index = _allJobs.indexWhere((j) => j.id == updatedJob.id);
    if (index != -1) {
      _allJobs[index] = updatedJob;
      notifyListeners();
    }
  }



  void assignJob(String jobId, String workerName, {String? workerPaymentInfo}) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    _allJobs[index] = _allJobs[index].copyWith(
      status: 'Assigned',
      workerName: workerName,
      workerPaymentInfo: workerPaymentInfo ?? _allJobs[index].workerPaymentInfo,
    );
    notifyListeners();
  }

  void rejectJob(String jobId, String workerName) {
    final set = _rejectedByWorker.putIfAbsent(workerName, () => <String>{});
    set.add(jobId);
    notifyListeners();
  }

  bool isRejectedFor(String jobId, String workerName) {
    final set = _rejectedByWorker[workerName];
    return set?.contains(jobId) ?? false;
  }

  // --- Payment / Escrow -------------------------------------------

  void payForJob(String jobId) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final txId = 'escrow-${DateTime.now().millisecondsSinceEpoch}';
    _allJobs[index] = _allJobs[index].copyWith(paid: true);
    _escrowTx[jobId] = txId;
    notifyListeners();
  }

  String? escrowTxFor(String jobId) => _escrowTx[jobId];

  List<Map<String, String>> escrowTxForWorker(String workerName) {
    final List<Map<String, String>> out = [];
    for (final job in _allJobs) {
      if (job.workerName == workerName && job.paid && job.status == 'Assigned') {
        final tx = _escrowTx[job.id] ?? 'on-chain';
        out.add({'title': job.title, 'tx': tx, 'amount': job.amount ?? '0'});
      }
    }
    return out;
  }

  // --- Job Completion ---------------------------------------------

  void completeJob(String jobId) {
    final index = _allJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(status: 'Completed');
      notifyListeners();
    }
  }

  // --- Ratings (Unified) ------------------------------------------

  /// Add or update a rating for either role
  void addRating({
    required String jobId,
    required String role, // 'worker' or 'client'
    required double rating,
    String? comment,
  }) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    final job = _allJobs[index];

    if (role == 'worker') {
      // Client rates the worker
      _allJobs[index] = job.copyWith(workerRating: rating);
    } else if (role == 'client') {
      // Worker rates the client
      _allJobs[index] = job.copyWith(clientRating: rating);
    }

    notifyListeners();
  }

  void setWorkerRating(String jobId, double rating) =>
      addRating(jobId: jobId, role: 'worker', rating: rating);

  void setClientRating(String jobId, double rating) =>
      addRating(jobId: jobId, role: 'client', rating: rating);

  // --- Recommendations --------------------------------------------

  List<Job> getRecommendedJobs(String workerName) {
    final workerJobs = allJobs.where((job) => job.workerName == workerName).toList();
    if (workerJobs.isEmpty) return allJobs.take(3).toList();

    final categories = <String, int>{};
    for (var job in workerJobs) {
      final cat = job.jobType ?? 'General';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    final favCategory =
        categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return allJobs
        .where((job) =>
            (job.jobType ?? '').toLowerCase() == favCategory.toLowerCase() &&
            job.workerName == null)
        .take(3)
        .toList();
  }

  // --- Placeholders for future networking --------------------------

  void fetchJobs() {}
  void applyForJob(String id) {}
}