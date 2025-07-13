import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/account_model.dart';
import 'package:tracker/haushaltsbuch/account_service.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final AccountService _accountService = AccountService();
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  void _loadAccounts() async {
    final accounts = await _accountService.getAccounts();
    setState(() {
      _accounts = accounts;
    });
  }

  void _showAccountDialog({Account? account}) {
    final _formKey = GlobalKey<FormState>();
    final isEditing = account != null;
    final nameController = TextEditingController(text: account?.name);
    final balanceController = TextEditingController(text: account?.balance.toString());
    bool includeInForecast = account?.includeInForecast ?? true;
    bool isDefault = account?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Konto bearbeiten' : 'Neues Konto anlegen'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Kontobezeichnung'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte geben Sie eine Kontobezeichnung ein.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Startbetrag'),
                  keyboardType: TextInputType.number,
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('In Prognose einbeziehen'),
                          value: includeInForecast,
                          onChanged: (bool? value) {
                            setState(() {
                              includeInForecast = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Als Standardkonto festlegen'),
                          value: isDefault,
                          onChanged: (bool? value) {
                            setState(() {
                              isDefault = value!;
                            });
                          },
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
                  final balance = double.tryParse(balanceController.text) ?? 0.0;

                  if (isEditing) {
                    final updatedAccount = Account(
                      id: account.id,
                      name: name,
                      balance: balance,
                      includeInForecast: includeInForecast,
                      isDefault: isDefault,
                    );
                    await _accountService.updateAccount(updatedAccount);
                  } else {
                    final newAccount = Account(
                      name: name,
                      balance: balance,
                      includeInForecast: includeInForecast,
                      isDefault: isDefault,
                    );
                    await _accountService.createAccount(newAccount);
                  }
                  _loadAccounts();
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
        title: const Text('Konten'),
      ),
      body: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return ListTile(
            title: Text(account.name),
            subtitle: Text('Betrag: ${account.balance.toStringAsFixed(2)} | Prognose: ${account.includeInForecast ? 'Ja' : 'Nein'} | Standard: ${account.isDefault ? 'Ja' : 'Nein'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAccountDialog(account: account),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _accountService.deleteAccount(account.id!);
                    _loadAccounts();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}