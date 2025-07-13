import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:tracker/haushaltsbuch/transaction_service.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key});

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Account? _selectedAccount;
  Category? _selectedCategory;

  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final TransactionService _transactionService = TransactionService();

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    _accounts = await _accountService.getAccounts();
    _categories = await _categoryService.getCategories();

    // Set default account if available
    _selectedAccount = await _accountService.getDefaultAccount();

    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte wählen Sie ein Konto aus.')),
        );
        return;
      }
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte wählen Sie eine Kategorie aus.')),
        );
        return;
      }

      final newTransaction = Transaction(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        accountId: _selectedAccount!.id!,
        categoryId: _selectedCategory!.id!,
      );

      await _transactionService.createTransaction(newTransaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Buchung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie eine Beschreibung ein.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Betrag'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie einen Betrag ein.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Bitte geben Sie eine gültige Zahl ein.';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Datum: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<Account>(
                value: _selectedAccount,
                decoration: const InputDecoration(labelText: 'Konto'),
                items: _accounts.map((account) {
                  return DropdownMenuItem<Account>(
                    value: account,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (Account? newValue) {
                  setState(() {
                    _selectedAccount = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Bitte wählen Sie ein Konto aus.';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategorie'),
                items: _categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Bitte wählen Sie eine Kategorie aus.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Buchung speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}