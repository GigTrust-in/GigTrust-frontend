// lib/providers/job_provider.dart
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_status.dart';
import '../data/sample_jobs.dart';

class JobProvider with ChangeNotifier {
  final List<Job> _allJobs = [...sampleJobs];
  final Map<String, Set<String>> _rejectedByWorker = {};
  final Map<String, String> _escrowTx = {};

  List<Job> get allJobs => [..._allJobs];

  List<Job> getOngoingJobs({required bool isWorker, required String userName}) => _allJobs
      .where((job) {
        final isOngoing = job.status == JobStatus.open ||
                         job.status == JobStatus.assigned ||
                         job.status == JobStatus.pendingCompletion;
        
        if (!isOngoing) return false;
        
        return isWorker 
            ? job.workerName == userName
            : job.clientName == userName;
      })
      .toList();

  List<Job> get pastJobs => _allJobs
      .where((job) => job.status == JobStatus.completed ||
                      job.status == JobStatus.cancelled)
      .toList();


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



  /// Validates and executes a job status transition
  void _transitionJobStatus(String jobId, String newStatus, {
    String? workerName,
    String? workerPaymentInfo,
    String? feedback,
  }) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');
    
    final job = _allJobs[index];
    if (!JobStatus.isValidTransition(job.status, newStatus)) {
      throw Exception('Invalid status transition from ${job.status} to $newStatus');
    }

    final now = DateTime.now();
    var updatedJob = job.copyWith(status: newStatus);

    // Add additional data based on the transition
    switch (newStatus) {
      case JobStatus.assigned:
        if (workerName == null || workerName.isEmpty) {
          throw Exception('Worker name is required for assignment');
        }
        updatedJob = updatedJob.copyWith(
          workerName: workerName,
          workerPaymentInfo: workerPaymentInfo,
          assignedAt: now,
        );
        _notifyStatusChange(job, 'assigned', workerName);
        break;

      case JobStatus.pendingCompletion:
        updatedJob = updatedJob.copyWith(pendingCompletionAt: now);
        _notifyStatusChange(job, 'completion_request');
        break;

      case JobStatus.completed:
        updatedJob = updatedJob.copyWith(
          completedAt: now,
          feedbackToWorker: feedback,
        );
        // Defer completion handling until after the updated job is persisted below
        break;

      case JobStatus.cancelled:
        _notifyStatusChange(job, 'cancelled');
        break;
    }

    _allJobs[index] = updatedJob;

    // If the job just moved to completed, handle payment/notifications now that
    // the persisted job reflects the completed status.
    if (newStatus == JobStatus.completed) {
      _handleJobCompletion(updatedJob);
    }

    notifyListeners();
  }

  /// Helper to send appropriate notifications for status changes
  void _notifyStatusChange(Job job, String type, [String? actorName]) {
    switch (type) {
      case 'assigned':
        addNotification(
          to: job.clientName,
          from: actorName,
          message: '${actorName ?? 'A worker'} has been assigned to "${job.title}"',
          type: 'job_assigned',
          jobId: job.id,
        );
        break;

      case 'completion_request':
        addNotification(
          to: job.clientName,
          from: job.workerName,
          message: '${job.workerName ?? 'Worker'} marked "${job.title}" as complete. Please review.',
          type: 'completion_request',
          jobId: job.id,
        );
        break;

      case 'cancelled':
        if (job.workerName != null) {
          addNotification(
            to: job.workerName!,
            from: job.clientName,
            message: 'Job "${job.title}" has been cancelled.',
            type: 'cancellation',
            jobId: job.id,
          );
        }
        break;
    }
  }

  /// Handle payment and notifications when a job is completed
  void _handleJobCompletion(Job job) {
    if (job.paid) {
      final txId = _escrowTx[job.id];
      if (txId != null) {
        _releasePayment(job.id, txId);
      }
    }

    addNotification(
      to: job.workerName!,
      from: job.clientName,
      message: 'Job "${job.title}" has been completed successfully!',
      type: 'completion',
      jobId: job.id,
    );
  }

  /// Assign a job to a worker
  void assignJob(String jobId, String workerName, {String? workerPaymentInfo}) {
    _transitionJobStatus(
      jobId,
      JobStatus.assigned,
      workerName: workerName,
      workerPaymentInfo: workerPaymentInfo,
    );
  }

  /// Worker cancels their assignment and returns the job to Open state.
  /// This is a worker-initiated unassign operation (not the same as client cancelling).
  void unassignJob(String jobId, String workerName) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');

    final job = _allJobs[index];
    if (job.workerName != workerName) {
      throw Exception('Only the assigned worker can unassign this job');
    }

    // Create an updated job reverting assignment fields
    final updated = job.copyWith(
      status: JobStatus.open,
      workerName: null,
      workerPaymentInfo: null,
      assignedAt: null,
      pendingCompletionAt: null,
    );

    _allJobs[index] = updated;

    // Notify the client that worker cancelled
    addNotification(
      to: job.clientName,
      from: workerName,
      message: 'Worker $workerName cancelled their assignment for "${job.title}"',
      type: 'worker_cancelled',
      jobId: jobId,
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

  /// Pay for a job, placing payment in escrow
  /// Returns the transaction ID for the escrow
  void payForJob(String jobId) {
    final index = _allJobs.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job not found');

    final job = _allJobs[index];
    if (job.paid) throw Exception('Job is already paid');

    // Create escrow transaction
    final txId = 'escrow-${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Here you would integrate with your payment gateway
      // For example:
      // await paymentGateway.createEscrow(
      //   amount: job.amount,
      //   jobId: jobId,
      //   txId: txId
      // );

      // Mark job as paid and store escrow transaction
      _allJobs[index] = job.copyWith(paid: true);
      _escrowTx[jobId] = txId;

      // Notify worker about payment
      if (job.workerName != null) {
        addNotification(
          to: job.workerName!,
          from: job.clientName,
          message: 'Payment for "${job.title}" has been placed in escrow',
          type: 'payment_escrow',
          jobId: jobId,
        );
      }

      notifyListeners();

    } catch (e) {
      throw Exception('Failed to create escrow: ${e.toString()}');
    }
  }

  /// Get escrow transaction ID for a specific job
  String? escrowTxFor(String jobId) => _escrowTx[jobId];

  /// Get all escrow transactions for a worker
  List<Map<String, String>> escrowTxForWorker(String workerName) {
    final List<Map<String, String>> out = [];
    for (final job in _allJobs) {
      if (job.workerName == workerName && 
          job.paid && 
          JobStatus.isOngoing(job.status)) {
        final tx = _escrowTx[job.id] ?? 'on-chain';
        out.add({
          'title': job.title, 
          'tx': tx, 
          'amount': job.amount ?? '0',
          'status': job.status
        });
      }
    }
    return out;
  }

  /// Get total amount in escrow for a worker
  String getTotalEscrowForWorker(String workerName) {
    var total = 0.0;
    for (final job in _allJobs) {
      if (job.workerName == workerName && 
          job.paid && 
          JobStatus.isOngoing(job.status)) {
        total += double.tryParse(job.amount ?? '0') ?? 0;
      }
    }
    return total.toStringAsFixed(2);
  }

  /// Get payment statistics for a worker
  Map<String, dynamic> getWorkerPaymentStats(String workerName) {
    var totalEarned = 0.0;
    var totalPending = 0.0;
    var completedJobs = 0;
    var pendingJobs = 0;

    for (final job in _allJobs) {
      if (job.workerName == workerName && job.paid) {
        final amount = double.tryParse(job.amount ?? '0') ?? 0;
        
        if (job.status == JobStatus.completed) {
          totalEarned += amount;
          completedJobs++;
        } else if (JobStatus.isOngoing(job.status)) {
          totalPending += amount;
          pendingJobs++;
        }
      }
    }

    return {
      'totalEarned': totalEarned.toStringAsFixed(2),
      'totalPending': totalPending.toStringAsFixed(2),
      'completedJobs': completedJobs,
      'pendingJobs': pendingJobs,
      'averagePerJob': completedJobs > 0 
        ? (totalEarned / completedJobs).toStringAsFixed(2) 
        : '0.00',
    };
  }

  /// Get payment statistics for a client
  Map<String, dynamic> getClientPaymentStats(String clientName) {
    var totalPaid = 0.0;
    var totalInEscrow = 0.0;
    var completedJobs = 0;
    var ongoingJobs = 0;

    for (final job in _allJobs) {
      if (job.clientName == clientName && job.paid) {
        final amount = double.tryParse(job.amount ?? '0') ?? 0;
        
        if (job.status == JobStatus.completed) {
          totalPaid += amount;
          completedJobs++;
        } else if (JobStatus.isOngoing(job.status)) {
          totalInEscrow += amount;
          ongoingJobs++;
        }
      }
    }

    return {
      'totalPaid': totalPaid.toStringAsFixed(2),
      'totalInEscrow': totalInEscrow.toStringAsFixed(2),
      'completedJobs': completedJobs,
      'ongoingJobs': ongoingJobs,
      'averageJobCost': completedJobs > 0 
        ? (totalPaid / completedJobs).toStringAsFixed(2) 
        : '0.00',
    };
  }

  /// Get transaction history for a user (either client or worker)
  List<Map<String, dynamic>> getTransactionHistory(String userName, {bool isWorker = true}) {
    final history = <Map<String, dynamic>>[];
    
    for (final job in _allJobs) {
      if ((isWorker && job.workerName == userName) ||
          (!isWorker && job.clientName == userName)) {
        
        if (job.paid) {
          final amount = job.amount ?? '0';
          final txId = _escrowTx[job.id] ?? 'direct';
          
          history.add({
            'jobId': job.id,
            'title': job.title,
            'amount': amount,
            'status': job.status,
            'txId': txId,
            'timestamp': job.completedAt ?? job.assignedAt ?? DateTime.now(),
            'type': JobStatus.shouldReleaseEscrow(job.status) ? 'completed' : 'escrow',
            'counterparty': isWorker ? job.clientName : job.workerName,
          });
        }
      }
    }
    
    // Sort by timestamp descending
    history.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return history;
  }

  // --- Job Completion ---------------------------------------------

  /// Mark a job as complete by the worker
  void markJobComplete(String jobId) {
    _transitionJobStatus(jobId, JobStatus.pendingCompletion);
  }

  /// Confirm job completion by the client
  /// Can either mark as completed or request revisions
  void confirmJobCompletion(String jobId, {required bool isCompleted, String? grievance}) {
    if (isCompleted) {
      _transitionJobStatus(jobId, JobStatus.completed, feedback: grievance);
    } else {
      final job = _allJobs.firstWhere((j) => j.id == jobId);
      _transitionJobStatus(jobId, JobStatus.assigned);
      
      // Send revision notification
      addNotification(
        to: job.workerName!,
        from: job.clientName,
        message: 'Job "${job.title}" requires revisions.\nFeedback: ${grievance ?? 'No specific feedback provided'}',
        type: 'revision',
        jobId: jobId,
      );
    }
  }

  /// Private helper to handle payment release
  void _releasePayment(String jobId, String txId) {
    final job = _allJobs.firstWhere((j) => j.id == jobId);
    
    // Validate payment can be released
    if (!JobStatus.shouldReleaseEscrow(job.status)) {
      throw Exception('Cannot release payment for job in ${job.status} state');
    }

    try {
      // Here you would integrate with your payment gateway
      // For example:
      // await paymentGateway.releaseEscrow(
      //   txId: txId,
      //   amount: job.amount,
      //   recipient: job.workerPaymentInfo,
      // );

      // Remove from escrow tracking after successful release
      _escrowTx.remove(jobId);

      // Notify worker of payment release
      addNotification(
        to: job.workerName!,
        from: job.clientName,
        message: 'Payment for "${job.title}" has been released to your account',
        type: 'payment_release',
        jobId: jobId,
      );

    } catch (e) {
      // If payment release fails, restore the escrow state
      _escrowTx[jobId] = txId;
      
      // Notify relevant parties of the failure
      for (final user in [job.workerName, job.clientName]) {
        if (user != null) {
          addNotification(
            to: user,
            from: 'System',
            message: 'Failed to process payment for "${job.title}". Please contact support.',
            type: 'payment_error',
            jobId: jobId,
          );
        }
      }
      
      throw Exception('Failed to release payment: ${e.toString()}');
    }
  }

  // --- Job Notifications ----------------------------------------

    final List<Map<String, dynamic>> _notifications = [];
  final int _maxNotifications = 100; // Limit per user
  List<Map<String, dynamic>> getNotificationsForUser(String userName) {
    return _notifications
        .where((n) => n['to'] == userName)
        .toList()
        .reversed
        .toList();
  }

  /// Get unread notification count for a user
  int getUnreadCount(String userName) {
    return _notifications
        .where((n) => n['to'] == userName && !(n['read'] as bool))
        .length;
  }

  /// Add a new notification
  /// Handles notification limits and duplicate prevention
  void addNotification({
    required String to,
    required String message,
    required String type,
    required String jobId,
    String? from,
  }) {
    // Prevent duplicate notifications
    final isDuplicate = _notifications.any((n) =>
        n['to'] == to &&
        n['jobId'] == jobId &&
        n['type'] == type &&
        n['timestamp'].difference(DateTime.now()).inMinutes.abs() < 5);
    
    if (isDuplicate) return;

    // Add new notification
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'to': to,
      'from': from,
      'message': message,
      'type': type,
      'jobId': jobId,
      'timestamp': DateTime.now(),
      'read': false,
    };
    
    _notifications.add(notification);

    // Enforce per-user notification limit
    final userNotifs = _notifications.where((n) => n['to'] == to).toList();
    if (userNotifs.length > _maxNotifications) {
      // Remove oldest notifications beyond the limit
      final toRemove = userNotifs.length - _maxNotifications;
      for (var i = 0; i < toRemove; i++) {
        _notifications.remove(userNotifs[i]);
      }
    }

    notifyListeners();
  }

  /// Mark a notification as read
  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index] = {
        ..._notifications[index],
        'read': true,
      };
      notifyListeners();
    }
  }

  /// Mark all notifications as read for a user
  void markAllRead(String userName) {
    var updated = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i]['to'] == userName && !_notifications[i]['read']) {
        _notifications[i] = {
          ..._notifications[i],
          'read': true,
        };
        updated = true;
      }
    }
    if (updated) notifyListeners();
  }

  /// Remove a specific notification
  void removeNotification(Map<String, dynamic> notif) {
    final index = _notifications.indexWhere((n) =>
        n['id'] == notif['id'] ||
        (n['to'] == notif['to'] &&
         n['jobId'] == notif['jobId'] &&
         n['type'] == notif['type'] &&
         n['timestamp'] == notif['timestamp']));
    if (index != -1) {
      _notifications.removeAt(index);
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