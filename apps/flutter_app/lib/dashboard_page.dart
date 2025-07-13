import 'package:flutter/material.dart';
import 'package:tracker/models/task.dart';
import 'package:tracker/services/database_service.dart';
import 'package:tracker/models/note.dart';
import 'package:tracker/services/note_service.dart';
import 'package:tracker/models/habit.dart';
import 'package:tracker/services/habit_service.dart';
import 'package:tracker/notizen_page.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:tracker/haushaltsbuch/transaction_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';
import 'package:tracker/haushaltsbuch/transaction_type.dart';
import 'package:tracker/haushaltsbuch/new_transaction_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DatabaseService _dbService = DatabaseService();
  final NoteService _noteService = NoteService();
  final HabitService _habitService = HabitService();
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();

  List<Task> _tasks = [];
  List<Note> _notes = [];
  List<Habit> _habits = [];
  List<Account> _accounts = [];
  List<Transaction> _transactions = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    _tasks = _dbService.getTasks();
    _notes = _noteService.getNotes();
    _habits = _habitService.getHabits();
    _accounts = await _accountService.getAccounts();
    _transactions = await _transactionService.getTransactions();
    _categories = await _categoryService.getCategories();
    setState(() {});
  }

  void _navigateToNewTransactionPage() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewTransactionPage()));
    _loadData(); // Reload data after new transaction is added
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _tasks.length;
    final highPriorityTasks = _tasks.where((task) => task.priority == Priority.hoch && !task.isCompleted).length;

    Task? nextDueTask;
    if (_tasks.isNotEmpty) {
      final openTasks = _tasks.where((task) => !task.isCompleted).toList();
      if (openTasks.isNotEmpty) {
        openTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        nextDueTask = openTasks.first;
      }
    }

    final totalNotes = _notes.length;
    final allTags = _notes.expand((note) => note.tags).toList();
    final tagCounts = <String, int>{};
    for (var tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    final top3Tags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3TagNames = top3Tags.take(3).map((entry) => entry.key).toList();

    double totalBalance = _accounts.fold(0.0, (sum, account) => sum + account.balance);
    final latestTransactions = _transactions.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Kontenübersicht
          Card(
            child: Padding(
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
          ),
          const SizedBox(height: 16),

          // Letzte Buchungen
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Letzte Buchungen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (latestTransactions.isEmpty)
                    const Text('Keine Buchungen vorhanden.')
                  else
                    ...latestTransactions.map((transaction) {
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

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${transaction.description}: $subtitleText'),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Button für neue Buchung
          ElevatedButton.icon(
            onPressed: _navigateToNewTransactionPage,
            icon: const Icon(Icons.add),
            label: const Text('Neue Buchung'),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aufgabenübersicht',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Gesamtzahl der Aufgaben: $totalTasks'),
                        Text('Aufgaben mit hoher Priorität: $highPriorityTasks'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nächste fällige Aufgabe',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (nextDueTask != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Beschreibung: ${nextDueTask.description}'),
                              Text('Fälligkeit: ${nextDueTask.dueDate.toLocal().toString().split(' ')[0]}'),
                              Text('Priorität: ${nextDueTask.priority.toString().split('.').last}'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    nextDueTask!.isCompleted = true;
                                    _dbService.updateTask(nextDueTask);
                                    _loadData();
                                  });
                                },
                                child: const Text('Als erledigt markieren'),
                              ),
                            ],
                          )
                        else
                          const Text('Keine offenen Aufgaben.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notizenübersicht',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Gesamtzahl der Notizen: $totalNotes'),
                        const SizedBox(height: 8),
                        const Text('Häufigste Tags:'),
                        if (top3TagNames.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            children: top3TagNames.map((tag) => ActionChip(
                              label: Text(tag),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NotizenPage(selectedTag: tag),
                                  ),
                                );
                              },
                            )).toList(),
                          )
                        else
                          const Text('Keine Tags vorhanden.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gewohnheiten',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_habits.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _habits.map((habit) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${habit.description} (Level: ${habit.counterLevel}, Streak: ${habit.counterStreak})'),
                                  IconButton(
                                    icon: const Icon(Icons.check_box_outline_blank),
                                    onPressed: () async {
                                      await _habitService.checkOffHabit(habit.id);
                                      _loadData();
                                    },
                                  ),
                                ],
                              ),
                            )).toList(),
                          )
                        else
                          const Text('Keine Gewohnheiten vorhanden.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
