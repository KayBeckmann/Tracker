import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';
import 'package:tracker/haushaltsbuch/transaction_model.dart';
import 'package:tracker/haushaltsbuch/transaction_service.dart';
import 'package:tracker/haushaltsbuch/transaction_template_model.dart';
import 'package:tracker/haushaltsbuch/transaction_template_service.dart';

class NewTransactionPage extends StatefulWidget {
  final Transaction? transaction;

  const NewTransactionPage({super.key, this.transaction});

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
  CategoryType _transactionType = CategoryType.expense; // Default to expense

  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final TransactionService _transactionService = TransactionService();
  final TransactionTemplateService _templateService = TransactionTemplateService();

  List<Account> _accounts = [];
  List<Category> _categories = [];
  List<TransactionTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
    }
    _loadData();
  }

  void _loadData() async {
    _accounts = await _accountService.getAccounts();
    _categories = await _categoryService.getCategories();
    _templates = await _templateService.getTemplates();

    if (widget.transaction != null) {
      _selectedAccount = _accounts.firstWhereOrNull((acc) => acc.id == widget.transaction!.accountId);
      _selectedCategory = _categories.firstWhereOrNull((cat) => cat.id == widget.transaction!.categoryId);
      _transactionType = _selectedCategory?.type ?? CategoryType.expense;
    } else {
      // Set default account if available and ensure it's from the loaded list
      final defaultAccount = await _accountService.getDefaultAccount();
      if (defaultAccount != null) {
        _selectedAccount = _accounts.firstWhereOrNull((acc) => acc.id == defaultAccount.id);
      }
    }

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

      if (widget.transaction == null) {
        final newTransaction = Transaction(
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          accountId: _selectedAccount!.id!,
          categoryId: _selectedCategory!.id!,
        );
        await _transactionService.createTransaction(newTransaction);
      } else {
        final updatedTransaction = Transaction(
          id: widget.transaction!.id,
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          accountId: _selectedAccount!.id!,
          categoryId: _selectedCategory!.id!,
        );
        await _transactionService.updateTransaction(updatedTransaction);
      }
      Navigator.of(context).pop();
    }
  }

  void _saveAsTemplate() async {
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

      final newTemplate = TransactionTemplate(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        type: _transactionType,
        accountId: _selectedAccount!.id!,
        categoryId: _selectedCategory!.id!,
      );

      await _templateService.createTemplate(newTemplate);
      Navigator.of(context).pop();
    }
  }

  void _loadTemplate(TransactionTemplate template) {
    setState(() {
      _descriptionController.text = template.description;
      _amountController.text = template.amount.toString();
      _transactionType = template.type;
      _selectedAccount = _accounts.firstWhereOrNull((acc) => acc.id == template.accountId);
      _selectedCategory = _categories.firstWhereOrNull((cat) => cat.id == template.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _categories
        .where((cat) => cat.type == _transactionType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Neue Buchung' : 'Buchung bearbeiten'),
        actions: [
          PopupMenuButton<TransactionTemplate>(
            onSelected: _loadTemplate,
            itemBuilder: (context) => _templates.map((template) {
              return PopupMenuItem<TransactionTemplate>(
                value: template,
                child: Text(template.description),
              );
            }).toList(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.copy_all),
                  SizedBox(width: 4),
                  Text('Vorlage laden'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<CategoryType>(
                      title: const Text('Einnahme'),
                      value: CategoryType.income,
                      groupValue: _transactionType,
                      onChanged: (CategoryType? value) {
                        setState(() {
                          _transactionType = value!;
                          _selectedCategory = null; // Reset category on type change
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<CategoryType>(
                      title: const Text('Ausgabe'),
                      value: CategoryType.expense,
                      groupValue: _transactionType,
                      onChanged: (CategoryType? value) {
                        setState(() {
                          _transactionType = value!;
                          _selectedCategory = null; // Reset category on type change
                        });
                      },
                    ),
                  ),
                ],
              ),
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
                items: filteredCategories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (Category? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    if (newValue != null && newValue.defaultAccountId != null) {
                      _selectedAccount = _accounts.firstWhereOrNull((acc) => acc.id == newValue.defaultAccountId);
                    }
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
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _saveTransaction,
                          child: Text(widget.transaction == null ? 'Buchung speichern' : 'Buchung aktualisieren'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _saveAsTemplate,
                          child: const Text('Als Vorlage speichern'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Abbrechen'),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _saveTransaction,
                          child: Text(widget.transaction == null ? 'Buchung speichern' : 'Buchung aktualisieren'),
                        ),
                        ElevatedButton(
                          onPressed: _saveAsTemplate,
                          child: const Text('Als Vorlage speichern'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Abbrechen'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}