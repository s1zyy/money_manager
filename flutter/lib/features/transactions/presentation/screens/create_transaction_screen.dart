import 'package:flutter/material.dart';
import 'package:money_manager/injection_container.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';


class CreateTransactionScreen extends StatefulWidget {
  
  const CreateTransactionScreen({super.key,});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen>{

  final repository = sl<TransactionRepository>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _uuid = Uuid();

  bool _isLoading = false;
  

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    final category = _categoryController.text;

    if(amount == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input'),)
      );
      return;
    }

    setState(() {
     _isLoading = true;  
    });

    try{
      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        category: category,
        date: DateTime.now(),
        isSynced: false,
      );

      await repository.createTransaction(transaction);

      Navigator.pop(context, true);
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'),)
      );
    } finally {
      setState(() {
       _isLoading = false;  
      });
    }
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
            _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
              ),
          ]
        )
      )


    );
  }
}
