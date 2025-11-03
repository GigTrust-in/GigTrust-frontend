// lib/models/job.dart
class Job {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final String postedDate;
  final String status;
  final String? workerName;
  final String? amount;
  final String? tenure;
  final String? location;
  final String? jobType;
  final String? minRating;
  final String? experience;
  final String? skills;
  final bool paid;
  final double? clientRating;
  final double? workerRating;
  final String? workerPaymentInfo;

  Job({
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
  });

  get category => null;

  get budget => null;

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? clientName,
    String? postedDate,
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
    );
  }

  void operator [](String other) {}
}