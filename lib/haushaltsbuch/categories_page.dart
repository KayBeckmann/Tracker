import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';
import 'package:tracker/haushaltsbuch/category_model.dart';
import 'package:tracker/haushaltsbuch/category_service.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _categoryService = CategoryService();
  final AccountService _accountService = AccountService();
  List<Category> _categories = [];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final categories = await _categoryService.getCategories();
    final accounts = await _accountService.getAccounts();
    setState(() {
      _categories = categories;
      _accounts = accounts;
    });
  }

  void _showCategoryDialog({Category? category}) {
    final _formKey = GlobalKey<FormState>();
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name);
    CategoryType type = category?.type ?? CategoryType.expense;
    Account? selectedAccount = _accounts.firstWhereOrNull(
        (acc) => acc.id == category?.defaultAccountId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Kategorie bearbeiten' : 'Neue Kategorie anlegen'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Kategoriebezeichnung'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine Kategoriebezeichnung ein.';
                    }
                    return null;
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        RadioListTile<CategoryType>(
                          title: const Text('Einnahme'),
                          value: CategoryType.income,
                          groupValue: type,
                          onChanged: (CategoryType? value) {
                            setState(() {
                              type = value!;
                            });
                          },
                        ),
                        RadioListTile<CategoryType>(
                          title: const Text('Ausgabe'),
                          value: CategoryType.expense,
                          groupValue: type,
                          onChanged: (CategoryType? value) {
                            setState(() {
                              type = value!;
                            });
                          },
                        ),
                        DropdownButtonFormField<Account>(
                          value: selectedAccount,
                          decoration: const InputDecoration(labelText: 'Standardkonto'),
                          items: _accounts.map((account) {
                            return DropdownMenuItem<Account>(
                              value: account,
                              child: Text(account.name),
                            );
                          }).toList(),
                          onChanged: (Account? newValue) {
                            setState(() {
                              selectedAccount = newValue;
                            });
                          },
                          hint: const Text('Kein Standardkonto'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final name = nameController.text;

                  if (isEditing) {
                    final updatedCategory = Category(
                      id: category.id,
                      name: name,
                      type: type,
                      defaultAccountId: selectedAccount?.id,
                    );
                    await _categoryService.updateCategory(updatedCategory);
                  } else {
                    final newCategory = Category(
                      name: name,
                      type: type,
                      defaultAccountId: selectedAccount?.id,
                    );
                    await _categoryService.createCategory(newCategory);
                  }
                  _loadData();
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Speichern' : 'Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorien'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final defaultAccountName = _accounts
              .firstWhereOrNull((acc) => acc.id == category.defaultAccountId)
              ?.name ?? 'Kein Standardkonto';
          return ListTile(
            title: Text(category.name),
            subtitle: Text(
                'Typ: ${category.type == CategoryType.income ? 'Einnahme' : 'Ausgabe'} | Standardkonto: $defaultAccountName'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showCategoryDialog(category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _categoryService.deleteCategory(category.id!);
                    _loadData();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
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