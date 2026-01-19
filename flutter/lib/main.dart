import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/transaction_screen.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  final client = http.Client();
  final remoteDataSource = TransactionRemoteDataSource(client);
  final repository = TransactionRepositoryImpl(remoteDataSource);

  runApp(
    MoneyManagerApp(repository: repository),
  );
}

class MoneyManagerApp extends StatelessWidget {
  final TransactionRepository repository;

  const MoneyManagerApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TransactionsScreen(repository: repository),
    );
  }
}