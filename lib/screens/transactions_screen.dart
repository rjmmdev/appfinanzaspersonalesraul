import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import 'modern_add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> 
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  final dateFormat = DateFormat('dd/MM/yyyy');
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  TransactionType? _filterType;
  bool _showOnlyDeductible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Transacciones'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'all':
                    _filterType = null;
                    _showOnlyDeductible = false;
                    break;
                  case 'income':
                    _filterType = TransactionType.income;
                    _showOnlyDeductible = false;
                    break;
                  case 'expense':
                    _filterType = TransactionType.expense;
                    _showOnlyDeductible = false;
                    break;
                  case 'deductible':
                    _filterType = null;
                    _showOnlyDeductible = true;
                    break;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('Todas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'income',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: AppTheme.successColor, size: 20),
                    SizedBox(width: 8),
                    Text('Ingresos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'expense',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: AppTheme.errorColor, size: 20),
                    SizedBox(width: 8),
                    Text('Gastos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deductible',
                child: Row(
                  children: [
                    Icon(Icons.receipt, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Text('IVA Acreditable'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernAddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildTransactionsList(provider),
      ),
    );
  }

  Widget _buildTransactionsList(FinanceProvider provider) {
    List<Transaction> transactions = provider.transactions;
    
    // Aplicar filtros
    if (_filterType != null) {
      transactions = transactions.where((t) => t.type == _filterType).toList();
    }
    
    if (_showOnlyDeductible) {
      transactions = transactions.where((t) => t.isDeductibleIva).toList();
    }

    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final account = provider.accounts.firstWhere(
          (a) => a.id == transaction.accountId,
          orElse: () => Account(
            name: 'Cuenta desconocida',
            bankType: BankType.bbva,
            balance: 0,
            annualInterestRate: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(transaction.id),
            background: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Editar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            secondaryBackground: Container(
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // Editar
                _editTransaction(transaction);
                return false;
              } else {
                // Eliminar
                return await _confirmDelete(transaction);
              }
            },
            child: ModernCard(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTransactionIcon(transaction),
                    color: _getTransactionColor(transaction),
                    size: 24,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (transaction.isDeductibleIva)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'IVA',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getBankColor(account.bankType),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          account.name,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          dateFormat.format(transaction.transactionDate),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.category!,
                        style: TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (transaction.hasIva && transaction.ivaAmount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'IVA: ${currencyFormat.format(transaction.ivaAmount)}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == TransactionType.expense ? '-' : '+'}'
                      '${currencyFormat.format(transaction.amount)}',
                      style: TextStyle(
                        color: _getTransactionColor(transaction),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (transaction.invoiceUrls != null && transaction.invoiceUrls!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attachment,
                              size: 12,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${transaction.invoiceUrls!.length}',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
    
    if (result == true) {
      // Recargar datos si se editó la transacción
      setState(() {});
    }
  }

  Future<bool> _confirmDelete(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de eliminar esta transacción?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      color: _getTransactionColor(transaction),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dateFormat.format(transaction.transactionDate),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<FinanceProvider>();
        await provider.deleteTransaction(transaction.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transacción eliminada exitosamente'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  Widget _buildEmptyState() {
    String message = 'No hay transacciones';
    String subtitle = 'Agrega tu primera transacción';
    
    if (_filterType == TransactionType.income) {
      message = 'No hay ingresos';
      subtitle = 'Los ingresos aparecerán aquí';
    } else if (_filterType == TransactionType.expense) {
      message = 'No hay gastos';
      subtitle = 'Los gastos aparecerán aquí';
    } else if (_showOnlyDeductible) {
      message = 'No hay gastos deducibles';
      subtitle = 'Los gastos con IVA acreditable aparecerán aquí';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return AppTheme.successColor;
      case TransactionType.expense:
        return AppTheme.errorColor;
      case TransactionType.transfer:
        return AppTheme.infoColor;
    }
  }

  IconData _getTransactionIcon(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
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