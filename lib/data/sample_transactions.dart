import '../models/transaction.dart';

final List<Transaction> sampleTransactions = [
  Transaction(
    id: 'tx-1',
    jobTitle: 'Mobile App Development',
    amount: 500.0,
    date: '2025-10-25',
    status: 'Completed',
    type: 'Payout',
  ),
  Transaction(
    id: 'tx-2',
    jobTitle: 'Website Design',
    amount: 300.0,
    date: '2025-10-24',
    status: 'Pending',
    type: 'Payment',
  ),
  Transaction(
    id: 'tx-3',
    jobTitle: 'Data Analysis',
    amount: 400.0,
    date: '2025-10-23',
    status: 'Completed',
    type: 'Payout',
  ),
];