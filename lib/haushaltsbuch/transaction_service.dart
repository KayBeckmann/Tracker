import 'package:tracker/database/database_helper.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:flutter/foundation.dart';

class TransactionService {
  final dbHelper = DatabaseHelper();

  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    final id = await db.insert('transactions', transaction.toMap());
    debugPrint('TransactionService: Created transaction with ID: $id');
    return id;
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query('transactions');
    debugPrint('TransactionService: Fetched ${maps.length} transactions.');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    debugPrint('TransactionService: Updated transaction with ID: ${transaction.id}, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('TransactionService: Deleted transaction with ID: $id, rows affected: $rowsAffected');
    return rowsAffected;
  }
}
