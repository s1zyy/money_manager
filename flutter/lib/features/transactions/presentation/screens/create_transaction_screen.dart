import 'package:flutter/material.dart';
import 'package:money_manager/features/transactions/presentation/transaction_bloc/transaction_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class CreateTransactionScreen extends StatefulWidget {

  final Transaction? transaction;
  
  const CreateTransactionScreen({super.key, this.transaction,});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen>{

  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _uuid = Uuid();  

  @override
  void initState(){
    super.initState();
    if (widget.transaction != null){
      _amountController.text = widget.transaction!.amount.toString();
      _categoryController.text = widget.transaction!.category;
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    final category = _categoryController.text;

    if(amount == null || category.isEmpty) {
      return;
    }

    
      final transaction = widget.transaction?.copyWith(
        amount: amount,
        category: category,
      ) ?? Transaction(
        id: _uuid.v4(),
        amount: amount,
        category: category,
        date: DateTime.now(),
        isSynced: false,
      );

      if(widget.transaction != null){
        context.read<TransactionBloc>().add(
          UpdateTransaction(transaction),
        );
        } else {
          context.read<TransactionBloc>().add(
        AddTransaction(transaction),
      );
      }
      


      Navigator.pop(context);
    
  }


  @override
  void dispose(){
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ]
        )
      )


    );
  }
}
