import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../providers/job_provider.dart';

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  String _selectedCard = 'Credit/Debit';
  String _selectedBrand = 'Visa';
  final List<String> _cardBrands = ['Visa', 'Mastercard', 'RuPay'];
  final List<String> _upiApps = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM'];
  String? _selectedUpi;
  double _amount = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null || user.role != Role.client) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: Text('Only clients can access payments')),
      );
    }

    // read optional arguments for job payment
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final jobId = args != null ? args['jobId'] as String? : null;
    final prefillAmount = args != null ? (args['amount'] as String?) : null;
    if (prefillAmount != null && prefillAmount.isNotEmpty) {
      _amount = double.tryParse(prefillAmount) ?? _amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateway')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '₹', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0.0),
            ),
            const SizedBox(height: 16),
            const Text('Pay with', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedCard,
              items: const [
                DropdownMenuItem(value: 'Credit/Debit', child: Text('Credit/Debit Card')),
                DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              ],
              onChanged: (v) => setState(() => _selectedCard = v ?? 'Credit/Debit'),
            ),
            const SizedBox(height: 12),
            if (_selectedCard == 'Credit/Debit') ...[
              const Text('Card Brand'),
              Wrap(
                spacing: 8,
                children: _cardBrands.map((b) {
                  return ChoiceChip(
                    label: Text(b),
                    selected: _selectedBrand == b,
                    onSelected: (_) => setState(() => _selectedBrand = b),
                  );
                }).toList(),
              ),
            ] else ...[
              const Text('UPI Apps'),
              Wrap(
                spacing: 8,
                children: _upiApps.map((u) {
                  return ChoiceChip(
                    label: Text(u),
                    selected: _selectedUpi == u,
                    onSelected: (_) => setState(() => _selectedUpi = u),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _amount <= 0
                    ? null
                    : () async {
                        // Simulate payment and mark job as paid (escrowed)
                        if (jobId != null) {
                          final jobProvider = Provider.of<JobProvider>(context, listen: false);
                          jobProvider.payForJob(jobId);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment of ₹${_amount.toStringAsFixed(0)} successful (escrowed)')),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Pay Now'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
