import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/job.dart';
import 'package:flutter_application_1/models/job_status.dart';
import 'package:flutter_application_1/providers/job_provider.dart';

void main() {
  group('JobProvider Payment Tests', () {
    late JobProvider provider;

    setUp(() {
      provider = JobProvider();
    });

    test('Pay for job creates escrow transaction', () {
      final now = DateTime.now();
      final job = Job(
        id: 'test-1',
        title: 'Test Job',
        description: 'Test Description',
        clientName: 'Client',
        amount: '100.00',
        status: JobStatus.open,
        postedDate: now,
      );

      provider.addJob(job);
      provider.payForJob('test-1');

      final txId = provider.escrowTxFor('test-1');
      expect(txId, isNotNull);
      expect(txId!.startsWith('escrow-'), isTrue);
    });

    test('Cannot pay for already paid job', () {
      final now = DateTime.now();
      final job = Job(
        id: 'test-1',
        title: 'Test Job',
        description: 'Test Description',
        clientName: 'Client',
        amount: '100.00',
        status: JobStatus.open,
        paid: true,
        postedDate: now,
      );

      provider.addJob(job);
      expect(
        () => provider.payForJob('test-1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('already paid'),
        )),
      );
    });

    test('Worker payment stats are calculated correctly', () {
      final now = DateTime.now();
      provider.addJob(Job(
        id: 'completed-1',
        title: 'Completed Job 1',
        description: 'Test',
        clientName: 'Client',
        workerName: 'Worker',
        amount: '100.00',
        status: JobStatus.completed,
        paid: true,
        postedDate: now,
      ));

      provider.addJob(Job(
        id: 'pending-1',
        title: 'Pending Job 1',
        description: 'Test',
        clientName: 'Client',
        workerName: 'Worker',
        amount: '50.00',
        status: JobStatus.pendingCompletion,
        paid: true,
        postedDate: now,
      ));

      final stats = provider.getWorkerPaymentStats('Worker');
      
      expect(stats['totalEarned'], equals('100.00'));
      expect(stats['totalPending'], equals('50.00'));
      expect(stats['completedJobs'], equals(1));
      expect(stats['pendingJobs'], equals(1));
      expect(stats['averagePerJob'], equals('100.00'));
    });

    test('Client payment stats are calculated correctly', () {
      final now = DateTime.now();
      provider.addJob(Job(
        id: 'completed-1',
        title: 'Completed Job 1',
        description: 'Test',
        clientName: 'Client',
        workerName: 'Worker1',
        amount: '100.00',
        status: JobStatus.completed,
        paid: true,
        postedDate: now,
      ));

      provider.addJob(Job(
        id: 'ongoing-1',
        title: 'Ongoing Job 1',
        description: 'Test',
        clientName: 'Client',
        workerName: 'Worker2',
        amount: '75.00',
        status: JobStatus.assigned,
        paid: true,
        postedDate: now,
      ));

      final stats = provider.getClientPaymentStats('Client');
      
      expect(stats['totalPaid'], equals('100.00'));
      expect(stats['totalInEscrow'], equals('75.00'));
      expect(stats['completedJobs'], equals(1));
      expect(stats['ongoingJobs'], equals(1));
      expect(stats['averageJobCost'], equals('100.00'));
    });

    test('Transaction history shows correct items', () {
      final now = DateTime.now();
      
      provider.addJob(Job(
        id: 'job-1',
        title: 'Test Job 1',
        description: 'Test',
        clientName: 'Client',
        workerName: 'Worker',
        amount: '100.00',
        status: JobStatus.completed,
        paid: true,
        postedDate: now,
        completedAt: now,
      ));

      final workerHistory = provider.getTransactionHistory('Worker', isWorker: true);
      expect(workerHistory.length, equals(1));
      expect(workerHistory[0]['type'], equals('completed'));
      expect(workerHistory[0]['amount'], equals('100.00'));
      expect(workerHistory[0]['counterparty'], equals('Client'));

      final clientHistory = provider.getTransactionHistory('Client', isWorker: false);
      expect(clientHistory.length, equals(1));
      expect(clientHistory[0]['type'], equals('completed'));
      expect(clientHistory[0]['amount'], equals('100.00'));
      expect(clientHistory[0]['counterparty'], equals('Worker'));
    });

    test('Escrow release happens on job completion', () {
      final now = DateTime.now();
      
      // Create job in pending completion state
      provider.addJob(Job(
        id: 'test-1',
        title: 'Test Job',
        description: 'Test Description',
        clientName: 'Client',
        workerName: 'Worker',
        amount: '100.00',
        status: JobStatus.pendingCompletion,
        paid: false,
        postedDate: now,
      ));

      // Set up escrow
      provider.payForJob('test-1');
      final txId = provider.escrowTxFor('test-1');
      expect(txId, isNotNull);

      // Complete the job - should trigger payment release
      provider.confirmJobCompletion('test-1', isCompleted: true);
      
      // Escrow should be cleared
      expect(provider.escrowTxFor('test-1'), isNull);
      
      // Worker should have notification about payment
      final notifications = provider.getNotificationsForUser('Worker')
          .where((n) => n['type'] == 'payment_release');
      expect(notifications, isNotEmpty);
    });
  });
}