class Transaction {
  final String id;
  final String jobTitle;
  final double amount;
  final String date;
  final String status;
  final String type; // 'Payout' or 'Payment'

  Transaction({
    required this.id,
    required this.jobTitle,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
  });
}