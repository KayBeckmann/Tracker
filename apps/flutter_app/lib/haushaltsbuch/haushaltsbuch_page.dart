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
import 'package:fl_chart/fl_chart.dart';

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
  List<FlSpot> _chartData = [];
  int _selectedTimeRange = 30; // 7, 30, 90 days

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
    _calculateChartData();
    setState(() {});
  }

  void _calculateChartData() {
    _chartData.clear();
    if (_transactions.isEmpty) return;

    DateTime endDate = DateTime.now();
    DateTime startDate;

    if (_selectedTimeRange == 7) {
      startDate = endDate.subtract(const Duration(days: 7));
    } else if (_selectedTimeRange == 90) {
      startDate = endDate.subtract(const Duration(days: 90));
    } else {
      startDate = endDate.subtract(const Duration(days: 30));
    }

    Map<DateTime, double> dailyBalance = {};
    double currentBalance = _accounts.fold(0.0, (sum, account) => sum + account.balance);

    // Initialize daily balances
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      dailyBalance[startDate.add(Duration(days: i))] = currentBalance;
    }

    // Apply transactions in reverse chronological order
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    for (var transaction in _transactions) {
      if (transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        // Adjust balance for transactions that occurred after the start date
        for (int i = 0; i <= endDate.difference(transaction.date).inDays; i++) {
          DateTime date = transaction.date.add(Duration(days: i));
          if (dailyBalance.containsKey(date)) {
            dailyBalance[date] = dailyBalance[date]! - transaction.amount;
          }
        }
      }
    }

    // Convert to FlSpot
    final sortedDates = dailyBalance.keys.toList()..sort((a, b) => a.compareTo(b));
    int dayIndex = 0;
    for (var date in sortedDates) {
      _chartData.add(FlSpot(dayIndex.toDouble(), dailyBalance[date]!));
      dayIndex++;
    }
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
          // Kapitalverlauf Graph
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kapitalverlauf',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTimeRange = 7;
                          _calculateChartData();
                        });
                      },
                      child: const Text('7 Tage'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTimeRange = 30;
                          _calculateChartData();
                        });
                      },
                      child: const Text('30 Tage'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedTimeRange = 90;
                          _calculateChartData();
                        });
                      },
                      child: const Text('Quartal'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
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