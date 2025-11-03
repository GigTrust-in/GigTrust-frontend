// lib/providers/job_provider.dart
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../data/sample_jobs.dart';

class JobProvider with ChangeNotifier {
  // ✅ Ensure sampleJobs is a List<Job>, not List<Map>
  final List<Job> _allJobs = [...sampleJobs];
  final Map<String, Set<String>> _rejectedByWorker = {};
  final Map<String, String> _escrowTx = {};

  List<Job> get allJobs => [..._allJobs];

  List<Job> get ongoingJobs => _allJobs
      .where((job) => job.status == 'Open' || job.status == 'Assigned')
      .toList();

  List<Job> get pastJobs =>
      _allJobs.where((job) => job.status == 'Completed').toList();

  // These return null (probably placeholders)
  List<Job>? get jobs => null;
  get availableJobs => null;

  // ✅ Add new job to top of the list
  void addJob(Job job) {
    _allJobs.insert(0, job);
    notifyListeners();
  }

  // ✅ Assign job to a worker
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

  // ✅ Reject job for a specific worker
  void rejectJob(String jobId, String workerName) {
    final set = _rejectedByWorker.putIfAbsent(workerName, () => <String>{});
    set.add(jobId);
    notifyListeners();
  }

  bool isRejectedFor(String jobId, String workerName) {
    final set = _rejectedByWorker[workerName];
    if (set == null) return false;
    return set.contains(jobId);
  }

  // ✅ Handle job payment
  void payForJob(String jobId) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final txId = 'escrow-${DateTime.now().millisecondsSinceEpoch}';
    _allJobs[index] = _allJobs[index].copyWith(paid: true);
    _escrowTx[jobId] = txId;
    notifyListeners();
  }

  String? escrowTxFor(String jobId) => _escrowTx[jobId];

  // ✅ Returns escrow transactions for a worker
  List<Map<String, String>> escrowTxForWorker(String workerName) {
    final List<Map<String, String>> out = [];
    for (final job in _allJobs) {
      if (job.workerName == workerName &&
          job.paid &&
          job.status == 'Assigned') {
        final tx = _escrowTx[job.id] ?? 'on-chain';
        out.add({'title': job.title, 'tx': tx, 'amount': job.amount ?? '0'});
      }
    }
    return out;
  }

  // ✅ Set ratings for both client and worker
  void setWorkerRating(String jobId, double rating) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    _allJobs[index] = _allJobs[index].copyWith(workerRating: rating);
    notifyListeners();
  }

  void setClientRating(String jobId, double rating) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    _allJobs[index] = _allJobs[index].copyWith(clientRating: rating);
    notifyListeners();
  }

  // ✅ Mark job as completed
  void completeJob(String jobId) {
    final index = _allJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      _allJobs[index] = _allJobs[index].copyWith(status: 'Completed');
      notifyListeners();
    }
  }

  // ✅ Filter jobs by type/category
  List<Job> filterJobsByCategory(String category) {
    if (category == 'All') return allJobs;
    return _allJobs
        .where(
          (job) => (job.jobType ?? '').toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // ✅ Unified rating method
  void addRating({
    required String jobId,
    required String role, // 'client' or 'worker'
    required double rating,
    String? comment,
  }) {
    final jobIndex = _allJobs.indexWhere((job) => job.id == jobId);
    if (jobIndex == -1) return;

    final job = _allJobs[jobIndex];

    if (role == 'worker') {
      _allJobs[jobIndex] = job.copyWith(clientRating: rating);
    } else if (role == 'client') {
      _allJobs[jobIndex] = job.copyWith(workerRating: rating);
    }

    // Optional: you can store comment later
    notifyListeners();
  }

  // ✅ Placeholders for future networking/database features
  void fetchJobs() {}
  void applyForJob(String id) {}
}