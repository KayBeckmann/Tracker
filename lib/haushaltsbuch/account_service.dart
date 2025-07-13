import 'package:tracker/database/database_helper.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:sqflite/sqflite.dart'; // Import for Database type

class AccountService {
  final dbHelper = DatabaseHelper();

  Future<int> createAccount(Account account) async {
    final db = await dbHelper.database;
    if (account.isDefault) {
      await _clearDefaultAccount(db);
    }
    final id = await db.insert('accounts', account.toMap());
    debugPrint('AccountService: Created account with ID: $id');
    return id;
  }

  Future<List<Account>> getAccounts() async {
    final db = await dbHelper.database;
    final maps = await db.query('accounts');
    debugPrint('AccountService: Fetched ${maps.length} accounts.');
    return List.generate(maps.length, (i) {
      return Account.fromMap(maps[i]);
    });
  }

  Future<int> updateAccount(Account account) async {
    final db = await dbHelper.database;
    if (account.isDefault) {
      await _clearDefaultAccount(db);
    }
    final rowsAffected = await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    debugPrint('AccountService: Updated account with ID: ${account.id}, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<int> deleteAccount(int id) async {
    final db = await dbHelper.database;
    final rowsAffected = await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('AccountService: Deleted account with ID: $id, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<void> _clearDefaultAccount(Database db) async {
    await db.update(
      'accounts',
      {'isDefault': 0},
      where: 'isDefault = ?',
      whereArgs: [1],
    );
  }

  Future<Account?> getDefaultAccount() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'accounts',
      where: 'isDefault = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }
}