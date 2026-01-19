import 'package:flutter/material.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/transaction_repository.dart';

class TransactionsScreen extends StatelessWidget {
  final TransactionRepository repository;
  const TransactionsScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),

      ),
      body: FutureBuilder<List<Transaction>>(
        future: repository.getTransactions(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(snapshot.hasError) {
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
                subtitle: Text('Amount: ${tx.amount}')
              );
            }
          );

        }
      )

    );
  }

}