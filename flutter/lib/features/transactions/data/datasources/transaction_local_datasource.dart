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
        'date': tx.date.toIso8601String(),
        'is_synced': tx.isSynced ? 1 : 0,
      },
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await AppDatabase.database;

    await db.update(
      'transactions',
      {
        'amount': transaction.amount,
        'category': transaction.category,
        'date': transaction.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
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
        'date': tx.date.toIso8601String(),
        'is_synced': tx.isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  
  }

  Future<List<Transaction>> getUnsyncedTransactions() async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return result.map((row) {
      return Transaction(
        id: row['id'].toString(),
        amount: row['amount'] as double,
        category: row['category'] as String,
        date: DateTime.parse(row['date'] as String),
        isSynced: false,
      );
    }).toList();
  }


  Future<void> markAsSynced(String id) async {
    final db = await AppDatabase.database;

    await db.update(
      'transactions',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
}