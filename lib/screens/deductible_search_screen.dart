import 'package:flutter/material.dart';
import '../data/resico_deductibles.dart';

class DeductibleSearchScreen extends StatefulWidget {
  const DeductibleSearchScreen({super.key});

  @override
  State<DeductibleSearchScreen> createState() => _DeductibleSearchScreenState();
}

class _DeductibleSearchScreenState extends State<DeductibleSearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = deductibleExpenses.where((expense) {
      final keywords = expense['keywords'] as List<String>;
      return query.isEmpty ||
          keywords.any((k) => k.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar gastos acreditables'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Ingresa un gasto (ej. comida)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final expense = results[index];
                return ListTile(
                  leading: Icon(
                    expense['deductible'] ? Icons.check_circle : Icons.cancel,
                    color: expense['deductible'] ? Colors.green : Colors.redAccent,
                  ),
                  title: Text(expense['name'] as String),
                  subtitle: Text(expense['detail'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
