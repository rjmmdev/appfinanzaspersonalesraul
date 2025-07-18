import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/account.dart';
import '../models/credit_card.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import 'modern_accounts_screen.dart';
import 'transactions_screen.dart';
import 'compatible_transaction_screen.dart';
import 'invoices_screen.dart';
import 'cfdi_guide_screen.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({super.key});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    // La carga de datos ya se hace en initializeDefaultAccounts() al crear el provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas Personales'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(provider),
              const SizedBox(height: 16),
              _buildQuickStats(provider),
              const SizedBox(height: 16),
              _buildAccountsSection(provider),
              const SizedBox(height: 16),
              _buildCreditCardsSection(provider),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 80),
            ],
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
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard(FinanceProvider provider) {
    final balancesBySource = provider.getBalancesBySource();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patrimonio Total',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(provider.totalBalances['netWorth'] ?? 0),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Balance por fuente (lo más importante)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Dinero del Trabajo',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormat.format(balancesBySource['work'] ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Dinero Personal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormat.format(balancesBySource['personal'] ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.family_restroom, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Dinero Familiar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormat.format(balancesBySource['family'] ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    'En Cuentas',
                    provider.totalBalances['totalInAccounts'] ?? 0,
                    Icons.savings,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceItem(
                    'Deudas',
                    provider.totalBalances['totalDebt'] ?? 0,
                    Icons.credit_card,
                    isDebt: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, IconData icon, {bool isDebt = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              color: isDebt ? Colors.red : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FinanceProvider provider) {
    final workTransactions = provider.getTransactionsBySource(MoneySource.work);
    final personalTransactions = provider.getTransactionsBySource(MoneySource.personal);
    final familyTransactions = provider.getTransactionsBySource(MoneySource.family);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transacciones por Fuente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Trabajo', workTransactions.length.toString(), Icons.work, Colors.orange),
                _buildStatItem('Personal', personalTransactions.length.toString(), Icons.person, Colors.blue),
                _buildStatItem('Familiar', familyTransactions.length.toString(), Icons.family_restroom, Colors.green),
                _buildStatItem('Cuentas', provider.accounts.length.toString(), Icons.account_balance, AppTheme.primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildAccountsSection(FinanceProvider provider) {
    return Card(
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
                        builder: (context) => const ModernAccountsScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.accounts.isEmpty)
              const Text('No hay cuentas disponibles')
            else
              ...provider.accounts.take(3).map((account) => _buildAccountItem(account)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(Account account) {
    final provider = context.read<FinanceProvider>();
    final accountBalances = provider.getAccountBalancesBySource();
    final balances = accountBalances[account.id] ?? {
      'personal': 0,
      'work': 0,
      'family': 0,
      'total': 0,
    };
    final isCredit = account.accountType == AccountType.credit;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getBankColor(account.bankType),
                radius: 20,
                child: Text(
                  account.bankType.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          account.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isCredit ? Colors.red[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isCredit ? 'Crédito' : 'Débito',
                            style: TextStyle(
                              fontSize: 10,
                              color: isCredit ? Colors.red[600] : Colors.green[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${account.annualInterestRate}% ${isCredit ? "interés" : "rendimiento"} anual',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(account.balance),
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                  color: isCredit && account.balance < 0 ? Colors.red : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSourceBalance('Trabajo', balances['work']!, Colors.orange),
                _buildSourceBalance('Personal', balances['personal']!, Colors.blue),
                _buildSourceBalance('Familiar', balances['family']!, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSourceBalance(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardsSection(FinanceProvider provider) {
    final creditCards = provider.creditCards;
    final creditAccounts = provider.creditAccounts;

    return Card(
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
              ...creditCards.map((card) => _buildCreditCardItem(card)),
              ...creditAccounts.map((acc) => _buildCreditAccountItem(acc)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardItem(CreditCard card) {
    final utilizationPercent = (card.currentBalance / card.creditLimit * 100);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.credit_card, color: Colors.white),
      ),
      title: Text(card.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Límite: ${currencyFormat.format(card.creditLimit)}'),
          LinearProgressIndicator(
            value: utilizationPercent / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              utilizationPercent > 80 ? Colors.red : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      trailing: Text(
        currencyFormat.format(card.currentBalance),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCreditAccountItem(Account account) {
    final limit = account.creditLimit ?? 0;
    final used = account.balance.abs();
    final utilizationPercent = limit > 0 ? used / limit * 100 : 0.0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getBankColor(account.bankType),
        child: const Icon(Icons.credit_card, color: Colors.white),
      ),
      title: Text(account.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Límite: ${currencyFormat.format(limit)}'),
          LinearProgressIndicator(
            value: utilizationPercent / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              utilizationPercent > 80 ? Colors.red : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      trailing: Text(
        currencyFormat.format(account.balance),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  'Trabajo',
                  Icons.work,
                  () => _showTransactionsBySource(MoneySource.work),
                  color: Colors.orange,
                ),
                _buildActionButton(
                  'Personal',
                  Icons.person,
                  () => _showTransactionsBySource(MoneySource.personal),
                  color: Colors.blue,
                ),
                _buildActionButton(
                  'Familiar',
                  Icons.family_restroom,
                  () => _showTransactionsBySource(MoneySource.family),
                  color: Colors.green,
                ),
                _buildActionButton(
                  'Todo',
                  Icons.receipt,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                  ),
                ),
                _buildActionButton(
                  'Cuentas',
                  Icons.account_balance,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ModernAccountsScreen()),
                  ),
                ),
                _buildActionButton(
                  'Facturas',
                  Icons.description,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InvoicesScreen()),
                  ),
                ),
                _buildActionButton(
                  'Guía CFDI',
                  Icons.help_outline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CFDIGuideScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color?.withOpacity(0.1) ?? Colors.grey[50],
        foregroundColor: color ?? Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color?.withOpacity(0.3) ?? Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionsBySource(MoneySource source) {
    final provider = context.read<FinanceProvider>();
    final filteredTransactions = provider.getTransactionsBySource(source);
    
    final sourceTitle = source == MoneySource.work 
        ? 'Trabajo' 
        : source == MoneySource.family 
            ? 'Familiar' 
            : 'Personal';
    final sourceColor = source == MoneySource.work 
        ? Colors.orange 
        : source == MoneySource.family 
            ? Colors.green 
            : Colors.blue;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      source == MoneySource.work 
                          ? Icons.work 
                          : source == MoneySource.family 
                              ? Icons.family_restroom 
                              : Icons.person,
                      color: sourceColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transacciones - $sourceTitle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: sourceColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sourceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredTransactions.length}',
                        style: TextStyle(
                          color: sourceColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              source == MoneySource.work 
                                  ? Icons.work_off 
                                  : source == MoneySource.family 
                                      ? Icons.family_restroom 
                                      : Icons.person_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay transacciones de $sourceTitle',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          final account = provider.accounts.firstWhere(
                            (a) => a.id == transaction.accountId,
                            orElse: () => Account(
                              name: 'Cuenta eliminada',
                              bankType: BankType.bbva,
                              accountType: AccountType.debit,
                              balance: 0,
                              annualInterestRate: 0,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                          );
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transaction.type == TransactionType.income
                                    ? AppTheme.successColor.withOpacity(0.1)
                                    : transaction.type == TransactionType.satDebt
                                        ? AppTheme.warningColor.withOpacity(0.1)
                                        : AppTheme.errorColor.withOpacity(0.1),
                                child: Icon(
                                  transaction.type == TransactionType.income
                                      ? Icons.arrow_downward
                                      : transaction.type == TransactionType.satDebt
                                          ? Icons.gavel
                                          : Icons.arrow_upward,
                                  color: transaction.type == TransactionType.income
                                      ? AppTheme.successColor
                                      : transaction.type == TransactionType.satDebt
                                          ? AppTheme.warningColor
                                          : AppTheme.errorColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                transaction.description,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(account.name),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(transaction.transactionDate),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${transaction.type == TransactionType.income ? '+' : '-'}${currencyFormat.format(transaction.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: transaction.type == TransactionType.income
                                          ? AppTheme.successColor
                                          : transaction.type == TransactionType.satDebt
                                              ? AppTheme.warningColor
                                              : AppTheme.errorColor,
                                    ),
                                  ),
                                  if (transaction.category != null)
                                    Text(
                                      transaction.category!,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBankColor(BankType bankType) {
    switch (bankType) {
      case BankType.bbva:
        return AppTheme.bbvaColor;
      case BankType.mercadoPago:
        return AppTheme.mercadoPagoColor;
      case BankType.nu:
        return AppTheme.nuColor;
      case BankType.didi:
        return AppTheme.didiColor;
    }
  }
}