/// Represents the possible states of a job in the system
class JobStatus {
  static const String open = 'Open';
  static const String assigned = 'Assigned';
  static const String pendingCompletion = 'PendingCompletion';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  /// Get all available job statuses
  static List<String> get values => [
    open,
    assigned,
    pendingCompletion,
    completed,
    cancelled,
  ];

  /// Check if a given status string is valid
  static bool isValid(String status) => values.contains(status);

  /// Get the next possible statuses from the current status
  static List<String> getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case open:
        return [assigned, cancelled];
      case assigned:
        return [pendingCompletion, cancelled];
      case pendingCompletion:
        return [completed, assigned]; // Can go back to assigned if revision needed
      case completed:
        return []; // Terminal state
      case cancelled:
        return []; // Terminal state
      default:
        return [];
    }
  }

  /// Check if a status transition is valid
  static bool isValidTransition(String from, String to) {
    return getNextStatuses(from).contains(to);
  }

  /// Get a user-friendly description of the status
  static String getDescription(String status) {
    switch (status) {
      case open:
        return 'Available for workers';
      case assigned:
        return 'Worker assigned and in progress';
      case pendingCompletion:
        return 'Waiting for client review';
      case completed:
        return 'Job completed successfully';
      case cancelled:
        return 'Job cancelled';
      default:
        return 'Unknown status';
    }
  }

  /// Get the display text for actions based on status
  static String getActionText(String status, {bool isWorker = true}) {
    if (isWorker) {
      switch (status) {
        case open:
          return 'Accept Job';
        case assigned:
          return 'Mark as Complete';
        case pendingCompletion:
          return 'Awaiting Review';
        case completed:
          return 'Completed';
        case cancelled:
          return 'Cancelled';
        default:
          return 'Unknown Action';
      }
    } else {
      // Client actions
      switch (status) {
        case open:
          return 'Awaiting Worker';
        case assigned:
          return 'In Progress';
        case pendingCompletion:
          return 'Review Completion';
        case completed:
          return 'Rate Worker';
        case cancelled:
          return 'Cancelled';
        default:
          return 'Unknown Action';
      }
    }
  }

  /// Check if a job status indicates ongoing work
  static bool isOngoing(String status) {
    return status == assigned || status == pendingCompletion;
  }

  /// Check if payments can be managed in this status
  static bool canManagePayments(String status) {
    // Payments can be made while job is ongoing or completed
    return isOngoing(status) || status == completed;
  }

  /// Check if ratings can be given in this status
  static bool canRate(String status) {
    // Only allow ratings for completed jobs
    return status == completed;
  }

  /// Check if escrow payment should be released
  static bool shouldReleaseEscrow(String status) {
    // Release payment only on completion
    return status == completed;
  }
}