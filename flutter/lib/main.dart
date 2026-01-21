import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:money_manager/features/transactions/data/datasources/transaction_remote_datasource.dart';

import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/transaction_screen.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';

void main() {
  final client = http.Client();
  final localDataSource = TransactionLocalDataSource();
  final remoteDataSource = TransactionRemoteDataSource(client);
  final repository = TransactionRepositoryImpl(localDataSource, remoteDataSource);

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