import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/features/transactions/presentation/transaction_bloc/transaction_bloc.dart';
import 'create_transaction_screen.dart';


class TransactionsScreen extends StatelessWidget {

  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      floatingActionButton: FloatingActionButton(     
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TransactionBloc>(),
                child: CreateTransactionScreen(),
              ),
              
            ),
          );

          
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if(state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions;
            if(transactions.isEmpty) {
              return const Center(child: Text('No transactions found.'));
            }
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
        } else if (state is TransactionError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return Container();
      },
      
    ),
    );
    
  }
}