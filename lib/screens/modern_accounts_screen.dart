import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

class ModernAccountsScreen extends StatefulWidget {
  const ModernAccountsScreen({super.key});

  @override
  State<ModernAccountsScreen> createState() => _ModernAccountsScreenState();
}

class _ModernAccountsScreenState extends State<ModernAccountsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    // Cargar datos al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Cuentas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await context.read<FinanceProvider>().loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos actualizados')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(),
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (provider.accounts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay cuentas bancarias'),
                  Text('Toca + para agregar una cuenta'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final account = provider.accounts[index];
              return _buildAccountCard(account, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildAccountCard(Account account, FinanceProvider provider) {
    final isCredit = account.accountType == AccountType.credit;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBankColor(account.bankType),
          child: Text(
            account.bankType.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(account.name),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCredit ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCredit ? 'Crédito' : 'Débito',
                style: TextStyle(
                  fontSize: 12,
                  color: isCredit ? Colors.red[700] : Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasa: ${account.annualInterestRate}% ${isCredit ? "interés" : "rendimiento"} anual'),
            Text(
              '${isCredit ? "Saldo: " : "Balance: "}${currencyFormat.format(account.balance)}',
              style: TextStyle(
                color: isCredit && account.balance < 0 ? Colors.red : null,
              ),
            ),
            if (isCredit && account.creditLimit != null)
              Text('Límite: ${currencyFormat.format(account.creditLimit)}'),
            if (isCredit && account.cutoffDate != null)
              Text('Corte: ${DateFormat('yyyy-MM-dd').format(account.cutoffDate!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit_balance':
                _showEditBalanceDialog(account, provider);
                break;
              case 'edit_rate':
                _showEditRateDialog(account, provider);
                break;
              case 'edit_account':
                _showEditAccountDialog(account, provider);
                break;
              case 'delete':
                _showDeleteDialog(account, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_balance',
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 20),
                  SizedBox(width: 8),
                  Text('Editar Balance'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit_rate',
              child: Row(
                children: [
                  Icon(Icons.percent, size: 20),
                  SizedBox(width: 8),
                  Text('Editar Tasa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit_account',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar Cuenta'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final rateController = TextEditingController(text: '0');
    final creditLimitController = TextEditingController();
    DateTime? selectedCutoffDate;
    BankType selectedBank = BankType.bbva;
    AccountType selectedAccountType = AccountType.debit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la cuenta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AccountType>(
                  value: selectedAccountType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cuenta',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AccountType.debit,
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Text('Débito'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: AccountType.credit,
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          const Text('Crédito'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedAccountType = value;
                        // Si es crédito, el balance inicial es negativo (deuda)
                        if (value == AccountType.credit && double.tryParse(balanceController.text) != null) {
                          final currentValue = double.parse(balanceController.text);
                          if (currentValue > 0) {
                            balanceController.text = (-currentValue).toString();
                          }
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BankType>(
                  value: selectedBank,
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    border: OutlineInputBorder(),
                  ),
                  items: BankType.values.map((bank) {
                    return DropdownMenuItem(
                      value: bank,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _getBankColor(bank),
                            child: Text(
                              bank.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(bank.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedBank = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  decoration: InputDecoration(
                    labelText: selectedAccountType == AccountType.credit 
                        ? 'Saldo actual (deuda)' 
                        : 'Balance inicial',
                    border: const OutlineInputBorder(),
                    prefixText: '\$ ',
                    helperText: selectedAccountType == AccountType.credit 
                        ? 'Ingresa el saldo como número negativo si es deuda' 
                        : null,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(
                    labelText: selectedAccountType == AccountType.credit
                        ? 'Tasa de interés anual (%)'
                        : 'Tasa de rendimiento anual (%)',
                    border: const OutlineInputBorder(),
                    suffixText: '%',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                if (selectedAccountType == AccountType.credit) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: creditLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Límite de crédito',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedCutoffDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedCutoffDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de corte',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedCutoffDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedCutoffDate!)
                            : 'Selecciona una fecha',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un nombre')),
                );
                return;
              }

              final balance = double.tryParse(balanceController.text) ?? 0;
              final rate = double.tryParse(rateController.text) ?? 0;
              final creditLimit = double.tryParse(creditLimitController.text);

              try {
                await context.read<FinanceProvider>().addAccount(
                  name: nameController.text.trim(),
                  bankType: selectedBank,
                  accountType: selectedAccountType,
                  initialBalance: balance,
                  annualInterestRate: rate,
                  creditLimit: creditLimit,
                  cutoffDate: selectedCutoffDate,
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  // Forzar recarga de datos
                  await context.read<FinanceProvider>().loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta agregada exitosamente')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
  }

  void _showEditBalanceDialog(Account account, FinanceProvider provider) {
    final controller = TextEditingController(text: account.balance.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Balance - ${account.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo balance',
            border: OutlineInputBorder(),
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newBalance = double.tryParse(controller.text);
              if (newBalance == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un balance válido')),
                );
                return;
              }

              try {
                await provider.updateAccountBalance(account.id!, newBalance);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Balance actualizado')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditRateDialog(Account account, FinanceProvider provider) {
    final controller = TextEditingController(text: account.annualInterestRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Tasa - ${account.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tasa de interés anual (%)',
            border: OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRate = double.tryParse(controller.text);
              if (newRate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa una tasa válida')),
                );
                return;
              }

              try {
                await provider.updateAccountRate(account.id!, newRate);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tasa actualizada')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(Account account, FinanceProvider provider) {
    final nameController = TextEditingController(text: account.name);
    final creditLimitController =
        TextEditingController(text: account.creditLimit?.toString() ?? '');
    DateTime? selectedCutoffDate = account.cutoffDate;
    BankType selectedBank = account.bankType;
    AccountType selectedAccountType = account.accountType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la cuenta',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AccountType>(
                  value: selectedAccountType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cuenta',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AccountType.debit,
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Text('Débito'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: AccountType.credit,
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          const Text('Crédito'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedAccountType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<BankType>(
                  value: selectedBank,
                  decoration: const InputDecoration(
                    labelText: 'Banco',
                    border: OutlineInputBorder(),
                  ),
                  items: BankType.values.map((bank) {
                    return DropdownMenuItem(
                      value: bank,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _getBankColor(bank),
                            child: Text(
                              bank.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(bank.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedBank = value;
                      });
                    }
                  },
                ),
                if (selectedAccountType == AccountType.credit) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: creditLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Límite de crédito',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedCutoffDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedCutoffDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de corte',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        selectedCutoffDate != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(selectedCutoffDate!)
                            : 'Selecciona una fecha',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor ingresa un nombre')),
                  );
                  return;
                }

                try {
                  await provider.updateAccount(
                    account.id!,
                    nameController.text.trim(),
                    selectedBank,
                    selectedAccountType,
                    creditLimit: double.tryParse(creditLimitController.text),
                    cutoffDate: selectedCutoffDate,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta actualizada')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Account account, FinanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: Text('¿Estás seguro que deseas eliminar la cuenta "${account.name}"?\n\nEsta acción no se puede deshacer y se eliminarán todas las transacciones asociadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteAccount(account.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
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