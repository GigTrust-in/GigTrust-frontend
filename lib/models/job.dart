class Job {
  final String id;
  final String title;
  final String description;
  final String clientName;
  final String postedDate;
  final String status;
  final String? workerName;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.postedDate,
    required this.status,
    this.workerName,
  });
}