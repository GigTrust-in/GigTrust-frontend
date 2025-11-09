// lib/models/job.dart
class Job {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final DateTime postedDate;
  final String status;
  final DateTime? assignedAt;
  final DateTime? pendingCompletionAt;
  final DateTime? completedAt;
  final String? workerName;
  final String? amount;
  final String? tenure;
  final String? location;
  final String? jobType;
  final String? minRating;
  final String? experience;
  final String? skills;
  final bool paid;
  final double? clientRating; // Worker → Client
  final double? workerRating; // Client → Worker
  final String? workerPaymentInfo;
  final String? feedbackToClient;
  final String? feedbackToWorker;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.postedDate,
    required this.status,
    this.workerName,
    this.amount,
    this.tenure,
    this.location,
    this.jobType,
    this.minRating,
    this.experience,
    this.skills,
    this.paid = false,
    this.clientRating,
    this.workerRating,
    this.workerPaymentInfo,
    this.feedbackToClient,
    this.feedbackToWorker,
    this.assignedAt,
    this.pendingCompletionAt,
    this.completedAt,
  });

  bool get isClientRated => workerRating != null;
  bool get isWorkerRated => clientRating != null;

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? clientName,
    DateTime? postedDate,
    String? status,
    String? workerName,
    String? amount,
    String? tenure,
    String? location,
    String? jobType,
    String? minRating,
    String? experience,
    String? skills,
    bool? paid,
    double? clientRating,
    double? workerRating,
    String? workerPaymentInfo,
    String? feedbackToClient,
    String? feedbackToWorker,
    DateTime? assignedAt,
    DateTime? pendingCompletionAt,
    DateTime? completedAt,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientName: clientName ?? this.clientName,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      workerName: workerName ?? this.workerName,
      amount: amount ?? this.amount,
      tenure: tenure ?? this.tenure,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      minRating: minRating ?? this.minRating,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      paid: paid ?? this.paid,
      clientRating: clientRating ?? this.clientRating,
      workerRating: workerRating ?? this.workerRating,
      workerPaymentInfo: workerPaymentInfo ?? this.workerPaymentInfo,
      feedbackToClient: feedbackToClient ?? this.feedbackToClient,
      feedbackToWorker: feedbackToWorker ?? this.feedbackToWorker,
      assignedAt: assignedAt ?? this.assignedAt,
      pendingCompletionAt: pendingCompletionAt ?? this.pendingCompletionAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}