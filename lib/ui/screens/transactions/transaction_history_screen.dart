import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  // Mock transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'date': '2025-04-17 14:30',
      'amount': 1500.00,
      'type': 'UPI',
      'recipient': 'john.doe@upi',
      'status': 'Completed',
      'isSuspicious': false,
    },
    {
      'id': 'TXN002',
      'date': '2025-04-17 12:15',
      'amount': 750.00,
      'type': 'Card',
      'recipient': 'Amazon India',
      'status': 'Completed',
      'isSuspicious': true,
    },
    {
      'id': 'TXN003',
      'date': '2025-04-16 09:45',
      'amount': 2000.00,
      'type': 'Wallet',
      'recipient': 'Uber India',
      'status': 'Pending',
      'isSuspicious': false,
    },
    {
      'id': 'TXN004',
      'date': '2025-04-15 18:20',
      'amount': 300.00,
      'type': 'UPI',
      'recipient': 'cafe.latte@upi',
      'status': 'Completed',
      'isSuspicious': true,
    },
  ];

  // Filter states
  bool _showUPI = true;
  bool _showCard = true;
  bool _showWallet = true;
  bool _showSuspicious = false;

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _transactions.where((txn) {
      if (_showSuspicious && !txn['isSuspicious']) return false;
      if (!_showUPI && txn['type'] == 'UPI') return false;
      if (!_showCard && txn['type'] == 'Card') return false;
      if (!_showWallet && txn['type'] == 'Wallet') return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];
                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.2,
                    isFirst: index == 0,
                    isLast: index == filteredTransactions.length - 1,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: transaction['isSuspicious']
                          ? Colors.red
                          : Colors.green,
                      iconStyle: transaction['isSuspicious']
                          ? IconStyle(
                              iconData: Icons.warning,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    beforeLineStyle: LineStyle(
                      color: transaction['isSuspicious']
                          ? Colors.red.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      thickness: 2,
                    ),
                    endChild: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildTransactionCard(transaction),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: transaction['isSuspicious']
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${transaction['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Chip(
                  label: Text(
                    transaction['status'],
                    style: TextStyle(
                      color: transaction['status'] == 'Completed'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: transaction['status'] == 'Completed'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${transaction['amount'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'To: ${transaction['recipient']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _getTypeIcon(transaction['type']),
                const SizedBox(width: 8),
                Text(
                  '${transaction['type']} • ${transaction['date']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (transaction['isSuspicious']) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Suspicious Transaction',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'UPI':
        return const Icon(Icons.payment, size: 16, color: Colors.blue);
      case 'Card':
        return const Icon(Icons.credit_card, size: 16, color: Colors.purple);
      case 'Wallet':
        return const Icon(Icons.account_balance_wallet,
            size: 16, color: Colors.orange);
      default:
        return const Icon(Icons.monetization_on, size: 16, color: Colors.grey);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Transactions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('UPI'),
                    value: _showUPI,
                    onChanged: (value) {
                      setDialogState(() {
                        _showUPI = value!;
                      });
                      setState(() {
                        _showUPI = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Card'),
                    value: _showCard,
                    onChanged: (value) {
                      setDialogState(() {
                        _showCard = value!;
                      });
                      setState(() {
                        _showCard = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Wallet'),
                    value: _showWallet,
                    onChanged: (value) {
                      setDialogState(() {
                        _showWallet = value!;
                      });
                      setState(() {
                        _showWallet = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Suspicious Only'),
                    value: _showSuspicious,
                    onChanged: (value) {
                      setDialogState(() {
                        _showSuspicious = value!;
                      });
                      setState(() {
                        _showSuspicious = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}