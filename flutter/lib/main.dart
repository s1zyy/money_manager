import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/injection_container.dart' as di;
import 'features/transactions/presentation/screens/transaction_screen.dart';
import 'features/transactions/presentation/transaction_bloc/transaction_bloc.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(
    BlocProvider(
      create: (_) => di.sl<TransactionBloc>()..add(LoadTransactions()),
      child: const MoneyManagerApp(),
    ),
  );
}

class MoneyManagerApp extends StatelessWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TransactionsScreen(),
    );
  }
}