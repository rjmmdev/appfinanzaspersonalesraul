import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/account.dart';
import '../models/credit_card.dart';
import 'accounts_screen.dart';
import 'transactions_screen.dart';
import 'compatible_transaction_screen.dart';
import 'cfdi_guide_screen.dart';
import 'deductible_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Finanzas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadData();
              // Los intereses se calculan automáticamente al iniciar la app
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 16),
                _buildAccountsList(provider),
                const SizedBox(height: 16),
                _buildCreditCardsList(provider),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompatibleTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(FinanceProvider provider) {
    final balances = provider.totalBalances;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Total',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('En cuentas:'),
                Text(
                  currencyFormat.format(balances['totalInAccounts'] ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Deuda tarjetas:'),
                Text(
                  currencyFormat.format(balances['totalDebt'] ?? 0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Patrimonio neto:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(balances['netWorth'] ?? 0),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: (balances['netWorth'] ?? 0) >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(FinanceProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cuentas Bancarias',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountsScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...provider.accounts.map((account) => _buildAccountTile(account)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile(Account account) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getBankColor(account.bankType),
        child: Text(
          account.bankType.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(account.name),
      subtitle: account.annualInterestRate > 0
          ? Text('${account.annualInterestRate}% anual')
          : null,
      trailing: Text(
        currencyFormat.format(account.balance),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: account.balance >= 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildCreditCardsList(FinanceProvider provider) {
    final creditCards = provider.creditCards;
    final creditAccounts = provider.creditAccounts;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tarjetas de Crédito',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (creditCards.isEmpty && creditAccounts.isEmpty)
              const Text('No hay tarjetas disponibles')
            else ...[
              ...creditCards.map((card) => _buildCreditCardTile(card)),
              ...creditAccounts.map((account) => _buildAccountCardAsCredit(account)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardTile(CreditCard card) {
    final usagePercent = card.usagePercentage;
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.purple,
        child: Icon(Icons.credit_card, color: Colors.white),
      ),
      title: Text(card.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Límite: ${currencyFormat.format(card.creditLimit)}'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: usagePercent / 100,
            backgroundColor: Colors.grey[300],
            color: usagePercent > 80 ? Colors.red : Colors.blue,
          ),
          const SizedBox(height: 2),
          Text('${usagePercent.toStringAsFixed(1)}% utilizado'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(card.currentBalance),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            'Disponible: ${currencyFormat.format(card.availableCredit)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildAccountCardAsCredit(Account account) {
    final limit = account.creditLimit ?? 0;
    final used = account.balance.abs();
    final available = limit - used;
    final usagePercent = limit > 0 ? (used / limit) * 100 : 0.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getBankColor(account.bankType),
        child: const Icon(Icons.credit_card, color: Colors.white),
      ),
      title: Text(account.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Límite: ${currencyFormat.format(limit)}'),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: usagePercent / 100,
            backgroundColor: Colors.grey[300],
            color: usagePercent > 80 ? Colors.red : Colors.blue,
          ),
          const SizedBox(height: 2),
          Text('${usagePercent.toStringAsFixed(1)}% utilizado'),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(account.balance),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            'Disponible: ${currencyFormat.format(available)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.receipt_long,
                  label: 'Transacciones',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.account_balance,
                  label: 'Cuentas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountsScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.assessment,
                  label: 'IVA RESICO',
                  onTap: () {
                    _showIvaReport(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.help_outline,
                  label: 'Guía CFDI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CFDIGuideScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.search,
                  label: 'Buscador IVA',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeductibleSearchScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getBankColor(BankType bankType) {
    switch (bankType) {
      case BankType.bbva:
        return Colors.blue;
      case BankType.mercadoPago:
        return Colors.yellow[700]!;
      case BankType.nu:
        return Colors.purple;
      case BankType.didi:
        return Colors.orange;
    }
  }

  void _showIvaReport(BuildContext context) {
    final provider = context.read<FinanceProvider>();
    final deductibleTransactions = provider.getDeductibleTransactions();
    final totalIva = provider.getTotalDeductibleIva();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte IVA Acreditable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de transacciones con IVA acreditable: ${deductibleTransactions.length}'),
            const SizedBox(height: 8),
            Text(
              'Total IVA acreditable: ${currencyFormat.format(totalIva)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}