import 'package:flutter/material.dart';
import 'package:money_manager/features/transactions/presentation/screens/create_transaction_screen.dart';
import 'package:money_manager/injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionsScreen extends StatefulWidget {

  const TransactionsScreen({
    super.key,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final repository = sl<TransactionRepository>();

  late Future<List<Transaction>> _future;

  @override
  void initState() {
    super.initState();
    _future = repository.getTransactions();
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
              builder: (_) => CreateTransactionScreen(),
            ),
          );

          if (result == true) {
            setState(() {
              _future = repository.getTransactions();
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
                title: Text(tx.category),
                subtitle: Text('Amount: ${tx.amount}'),
              );
            },
          );
        },
      ),
    );
  }
}