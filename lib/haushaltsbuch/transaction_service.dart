import 'package:tracker/database/database_helper.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/transaction_type.dart';

class TransactionService {
  final dbHelper = DatabaseHelper();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();

  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    final id = await db.insert('transactions', transaction.toMap());
    debugPrint('TransactionService: Created transaction with ID: $id');

    // Update account balance
    if (transaction.type == TransactionType.transfer) {
      final sourceAccount = await _accountService.getAccountById(transaction.accountId);
      final targetAccount = await _accountService.getAccountById(transaction.targetAccountId!);
      if (sourceAccount != null && targetAccount != null) {
        sourceAccount.balance -= transaction.amount;
        targetAccount.balance += transaction.amount;
        await _accountService.updateAccount(sourceAccount);
        await _accountService.updateAccount(targetAccount);
      }
    } else {
      final account = await _accountService.getAccountById(transaction.accountId);
      final category = await _categoryService.getCategoryById(transaction.categoryId);
      if (account != null && category != null) {
        debugPrint('TransactionService: Updating account balance for account ${account.name} (ID: ${account.id})');
        if (category.type == CategoryType.income) {
          account.balance += transaction.amount;
          debugPrint('TransactionService: Income - new balance: ${account.balance}');
        } else {
          account.balance -= transaction.amount;
          debugPrint('TransactionService: Expense - new balance: ${account.balance}');
        }
        await _accountService.updateAccount(account);
      }
    }

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
    // Get old transaction to revert balance change
    final oldTransaction = await getTransactionById(transaction.id!);
    if (oldTransaction != null) {
      if (oldTransaction.type == TransactionType.transfer) {
        final oldSourceAccount = await _accountService.getAccountById(oldTransaction.accountId);
        final oldTargetAccount = await _accountService.getAccountById(oldTransaction.targetAccountId!);
        if (oldSourceAccount != null && oldTargetAccount != null) {
          oldSourceAccount.balance += oldTransaction.amount;
          oldTargetAccount.balance -= oldTransaction.amount;
          await _accountService.updateAccount(oldSourceAccount);
          await _accountService.updateAccount(oldTargetAccount);
        }
      } else {
        final oldAccount = await _accountService.getAccountById(oldTransaction.accountId);
        final oldCategory = await _categoryService.getCategoryById(oldTransaction.categoryId);
        if (oldAccount != null && oldCategory != null) {
          debugPrint('TransactionService: Reverting old transaction balance for account ${oldAccount.name} (ID: ${oldAccount.id})');
          if (oldCategory.type == CategoryType.income) {
            oldAccount.balance -= oldTransaction.amount;
            debugPrint('TransactionService: Reverted Income - new balance: ${oldAccount.balance}');
          } else {
            oldAccount.balance += oldTransaction.amount;
            debugPrint('TransactionService: Reverted Expense - new balance: ${oldAccount.balance}');
          }
          await _accountService.updateAccount(oldAccount);
        }
      }
    }

    final rowsAffected = await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    debugPrint('TransactionService: Updated transaction with ID: ${transaction.id}, rows affected: $rowsAffected');

    // Apply new transaction balance change
    if (transaction.type == TransactionType.transfer) {
      final newSourceAccount = await _accountService.getAccountById(transaction.accountId);
      final newTargetAccount = await _accountService.getAccountById(transaction.targetAccountId!);
      if (newSourceAccount != null && newTargetAccount != null) {
        newSourceAccount.balance -= transaction.amount;
        newTargetAccount.balance += transaction.amount;
        await _accountService.updateAccount(newSourceAccount);
        await _accountService.updateAccount(newTargetAccount);
      }
    } else {
      final newAccount = await _accountService.getAccountById(transaction.accountId);
      final newCategory = await _categoryService.getCategoryById(transaction.categoryId);
      if (newAccount != null && newCategory != null) {
        debugPrint('TransactionService: Applying new transaction balance for account ${newAccount.name} (ID: ${newAccount.id})');
        if (newCategory.type == CategoryType.income) {
          newAccount.balance += transaction.amount;
          debugPrint('TransactionService: New Income - new balance: ${newAccount.balance}');
        } else {
          newAccount.balance -= transaction.amount;
          debugPrint('TransactionService: New Expense - new balance: ${newAccount.balance}');
        }
        await _accountService.updateAccount(newAccount);
      }
    }

    return rowsAffected;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    // Get transaction to revert balance change
    final transactionToDelete = await getTransactionById(id);
    if (transactionToDelete != null) {
      if (transactionToDelete.type == TransactionType.transfer) {
        final sourceAccount = await _accountService.getAccountById(transactionToDelete.accountId);
        final targetAccount = await _accountService.getAccountById(transactionToDelete.targetAccountId!);
        if (sourceAccount != null && targetAccount != null) {
          sourceAccount.balance += transactionToDelete.amount;
          targetAccount.balance -= transactionToDelete.amount;
          await _accountService.updateAccount(sourceAccount);
          await _accountService.updateAccount(targetAccount);
        }
      } else {
        final account = await _accountService.getAccountById(transactionToDelete.accountId);
        final category = await _categoryService.getCategoryById(transactionToDelete.categoryId);
        if (account != null && category != null) {
          debugPrint('TransactionService: Reverting balance for deleted transaction for account ${account.name} (ID: ${account.id})');
          if (category.type == CategoryType.income) {
            account.balance -= transactionToDelete.amount;
            debugPrint('TransactionService: Reverted Income (deleted) - new balance: ${account.balance}');
          } else {
            account.balance += transactionToDelete.amount;
            debugPrint('TransactionService: Reverted Expense (deleted) - new balance: ${account.balance}');
          }
          await _accountService.updateAccount(account);
        }
      }
    }

    final rowsAffected = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('TransactionService: Deleted transaction with ID: $id, rows affected: $rowsAffected');
    return rowsAffected;
  }

  Future<List<Transaction>> getTransferTransactions() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [TransactionType.transfer.index],
    );
    debugPrint('TransactionService: Fetched ${maps.length} transfer transactions.');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }
}