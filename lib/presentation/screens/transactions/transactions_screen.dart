import 'package:flutter/material.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Pantalla de Transacciones - En desarrollo'),
      ),
    );
  }
}