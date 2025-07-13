import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/accounts_page.dart';
import 'package:tracker/haushaltsbuch/categories_page.dart';
import 'package:tracker/haushaltsbuch/new_transaction_page.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:tracker/haushaltsbuch/transaction_service.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';

class HaushaltsbuchPage extends StatefulWidget {
  const HaushaltsbuchPage({super.key});

  @override
  State<HaushaltsbuchPage> createState() => _HaushaltsbuchPageState();
}

class _HaushaltsbuchPageState extends State<HaushaltsbuchPage> {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    _transactions = await _transactionService.getTransactions();
    _accounts = await _accountService.getAccounts();
    _categories = await _categoryService.getCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haushaltsbuch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoriesPage()));
            },
          ),
        ],
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('Keine Buchungen vorhanden.'))
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final account = _accounts.firstWhere(
                    (acc) => acc.id == transaction.accountId, orElse: () => Account(name: 'Unbekannt', balance: 0.0, includeInForecast: false));
                final category = _categories.firstWhere(
                    (cat) => cat.id == transaction.categoryId, orElse: () => Category(name: 'Unbekannt', type: CategoryType.expense));

                return ListTile(
                  title: Text(transaction.description),
                  subtitle: Text(
                      '${transaction.amount.toStringAsFixed(2)} € | ${transaction.date.toLocal().toString().split(' ')[0]} | ${account.name} | ${category.name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement edit transaction
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _transactionService.deleteTransaction(transaction.id!);
                          _loadData();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewTransactionPage()));
          _loadData(); // Reload data after new transaction is added
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
