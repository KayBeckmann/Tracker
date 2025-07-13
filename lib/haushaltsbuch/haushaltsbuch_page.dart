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
import 'package:tracker/haushaltsbuch/transaction_type.dart';

class HaushaltsbuchPage extends StatefulWidget {
  const HaushaltsbuchPage({super.key});

  @override
  State<HaushaltsbuchPage> createState() => _HaushaltsbuchPageState();
}

class _HaushaltsbuchPageState extends State<HaushaltsbuchPage> with WidgetsBindingObserver {
  final TransactionService _transactionService = TransactionService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  List<Transaction> _transactions = [];
  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() async {
    _transactions = await _transactionService.getTransactions();
    _accounts = await _accountService.getAccounts();
    _categories = await _categoryService.getCategories();
    setState(() {});
  }

  void _navigateToEditTransactionPage([Transaction? transaction]) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewTransactionPage(transaction: transaction)));
    _loadData(); // Reload data after new transaction is added or edited
  }

  @override
  Widget build(BuildContext context) {
    double totalBalance = _accounts.fold(0.0, (sum, account) => sum + account.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haushaltsbuch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AccountsPage()));
              _loadData(); // Reload data after returning from AccountsPage
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoriesPage()));
              _loadData(); // Reload data after returning from CategoriesPage
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontenübersicht',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._accounts.map((account) => Text('${account.name}: ${account.balance.toStringAsFixed(2)} €')),
                const Divider(),
                Text(
                  'Gesamtsaldo: ${totalBalance.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text('Keine Buchungen vorhanden.'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      final account = _accounts.firstWhere(
                          (acc) => acc.id == transaction.accountId, orElse: () => Account(name: 'Unbekannt', balance: 0.0, includeInForecast: false));
                      final category = _categories.firstWhere(
                          (cat) => cat.id == transaction.categoryId, orElse: () => Category(name: 'Unbekannt', type: CategoryType.expense));

                      String subtitleText;
                      if (transaction.type == TransactionType.transfer) {
                        final targetAccount = _accounts.firstWhere(
                            (acc) => acc.id == transaction.targetAccountId, orElse: () => Account(name: 'Unbekannt', balance: 0.0, includeInForecast: false));
                        subtitleText = '${transaction.amount.toStringAsFixed(2)} € | ${transaction.date.toLocal().toString().split(' ')[0]} | ${account.name} -> ${targetAccount.name}';
                      } else {
                        subtitleText = '${transaction.amount.toStringAsFixed(2)} € | ${transaction.date.toLocal().toString().split(' ')[0]} | ${account.name} | ${category.name}';
                      }

                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(subtitleText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToEditTransactionPage(transaction),
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
          ),
        ],
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
