import 'package:flutter/material.dart';

class NewTransactionPage extends StatelessWidget {
  const NewTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neue Buchung'),
      ),
      body: const Center(
        child: Text('Neue Buchung erstellen'),
      ),
    );
  }
}
