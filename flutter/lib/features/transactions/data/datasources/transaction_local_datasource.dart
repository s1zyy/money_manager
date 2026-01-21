import 'package:sqflite/sqlite_api.dart' hide Transaction;

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart';

class TransactionLocalDataSource {
  Future<List<Transaction>> getTransactions() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'transactions',
       orderBy: 'date DESC',
    );

    return result.map((row) {
      return Transaction(
        id: row['id'].toString(),
        amount: row['amount'] as double,
        category: row['category'] as String,
        date: DateTime.parse(row['date'] as String),
        isSynced: row['is_synced'] == 1,
      );
    }).toList();

  }

  Future<void> createTransaction(Transaction tx) async {
    final db = await AppDatabase.database;

    await db.insert(
      'transactions',
      {
        'id': tx.id,
        'amount': tx.amount,
        'category': tx.category,
        'date': tx.date!.toIso8601String(),
        'is_synced': tx.isSynced ? 1 : 0,
      },
    );
}

  Future<void> upsertTransaction(Transaction tx) async {
    final db = await AppDatabase.database;

    await db.insert(
      'transactions',
      {
        'id': tx.id,
        'amount': tx.amount,
        'category': tx.category,
        'date': tx.date!.toIso8601String(),
        'is_synced': tx.isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  
  }
}