import 'package:flutter/material.dart';
import 'package:money_manager/features/transactions/presentation/create_transaction_screen.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/transaction_repository.dart';

class TransactionsScreen extends StatefulWidget {
  final TransactionRepository repository;

  const TransactionsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<Transaction>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateTransactionScreen(
                repository: widget.repository,
              ),
            ),
          );

          if (result == true) {
            setState(() {
              _future = widget.repository.getTransactions();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final transactions = snapshot.data!;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return ListTile(
                title: Text(tx.category ?? 'No Category'),
                subtitle: Text('Amount: ${tx.amount}'),
              );
            },
          );
        },
      ),
    );
  }
}