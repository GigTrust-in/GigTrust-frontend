import 'package:flutter/material.dart';
import '../models/job.dart';
import '../data/sample_jobs.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _allJobs = [...sampleJobs];
  // track jobs rejected by workers so they don't see them again
  final Map<String, Set<String>> _rejectedByWorker = {};
  // track escrow transactions created when client pays for a job: jobId -> txId
  final Map<String, String> _escrowTx = {};

  List<Job> get allJobs => [..._allJobs];

  List<Job> get ongoingJobs =>
      _allJobs.where((job) => job.status == 'Open' || job.status == 'Assigned').toList();

  List<Job> get pastJobs =>
      _allJobs.where((job) => job.status == 'Completed').toList();

  void addJob(Job job) {
    _allJobs.add(job);
    notifyListeners();
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
    if (set == null) return false;
    return set.contains(jobId);
  }

  /// Mark a job as paid by client and create a simulated escrow tx id
  void payForJob(String jobId) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final txId = 'escrow-${DateTime.now().millisecondsSinceEpoch}';
    _allJobs[index] = _allJobs[index].copyWith(paid: true);
    _escrowTx[jobId] = txId;
    notifyListeners();
  }

  /// Return escrow tx id if job was paid
  String? escrowTxFor(String jobId) => _escrowTx[jobId];

  /// For a worker, return list of escrow transactions (job title and tx id)
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