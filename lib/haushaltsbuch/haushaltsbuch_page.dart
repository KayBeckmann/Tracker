import 'package:flutter/material.dart';
import 'package:tracker/haushaltsbuch/accounts_page.dart';
import 'package:tracker/haushaltsbuch/categories_page.dart';
import 'package:tracker/haushaltsbuch/new_transaction_page.dart';

class HaushaltsbuchPage extends StatelessWidget {
  const HaushaltsbuchPage({super.key});

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
      body: const Center(
        child: Text('Übersicht der Buchungen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewTransactionPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}