import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

class SimpleNewTransactionScreen extends StatefulWidget {
  const SimpleNewTransactionScreen({super.key});

  @override
  State<SimpleNewTransactionScreen> createState() => _SimpleNewTransactionScreenState();
}

class _SimpleNewTransactionScreenState extends State<SimpleNewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  // Transaction data
  TransactionType _selectedType = TransactionType.expense;
  int? _selectedAccountId;
  MoneySource _selectedSource = MoneySource.personal;
  bool _hasIva = false;
  bool _isDeductibleIva = false;
  String? _selectedCategory;
  String? _selectedUsoCFDI;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _expenseCategories = [
    'Alimentos y Bebidas',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Compras',
    'Hogar',
    'Ropa y Calzado',
    'Tecnología',
    'Mascotas',
    'Regalos',
    'Viajes',
    'Impuestos',
    'Seguros',
    'Ahorro e Inversión',
    'Deudas',
    'Otros Gastos',
  ];

  final List<String> _incomeCategories = [
    'Sueldo',
    'Freelance',
    'Inversiones',
    'Ventas',
    'Regalos',
    'Reembolsos',
    'Intereses',
    'Bonos',
    'Comisiones',
    'Rentas',
    'Dividendos',
    'Prestaciones',
    'Aguinaldo',
    'PTU',
    'Otros Ingresos',
  ];

  final Map<String, String> _usosCFDI = {
    'G01': 'Adquisición de mercancías',
    'G02': 'Devoluciones, descuentos o bonificaciones',
    'G03': 'Gastos en general',
    'I01': 'Construcciones',
    'I02': 'Mobiliario y equipo de oficina por inversiones',
    'I03': 'Equipo de transporte',
    'I04': 'Equipo de cómputo y accesorios',
    'I05': 'Dados, troqueles, moldes, matrices y herramental',
    'I06': 'Comunicaciones telefónicas',
    'I07': 'Comunicaciones satelitales',
    'I08': 'Otra maquinaria y equipo',
    'D01': 'Honorarios médicos, dentales y gastos hospitalarios',
    'D02': 'Gastos médicos por incapacidad o discapacidad',
    'D03': 'Gastos funerales',
    'D04': 'Donativos',
    'D05': 'Intereses reales efectivamente pagados por créditos hipotecarios',
    'D06': 'Aportaciones voluntarias al SAR',
    'D07': 'Primas por seguros de gastos médicos',
    'D08': 'Gastos de transportación escolar obligatoria',
    'D09': 'Depósitos en cuentas para el ahorro, primas de pensiones',
    'D10': 'Pagos por servicios educativos (colegiaturas)',
    'P01': 'Por definir',
    'S01': 'Sin efectos fiscales',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo de transacción', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Ingreso'),
                              value: TransactionType.income,
                              groupValue: _selectedType,
                              onChanged: (value) => setState(() {
                                _selectedType = value!;
                                _selectedCategory = null; // Reset category when type changes
                              }),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Gasto'),
                              value: TransactionType.expense,
                              groupValue: _selectedType,
                              onChanged: (value) => setState(() {
                                _selectedType = value!;
                                _selectedCategory = null; // Reset category when type changes
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Money Source
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fuente del dinero', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MoneySource>(
                        value: _selectedSource,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MoneySource.personal,
                            child: Text('Personal'),
                          ),
                          DropdownMenuItem(
                            value: MoneySource.work,
                            child: Text('Trabajo'),
                          ),
                          DropdownMenuItem(
                            value: MoneySource.family,
                            child: Text('Familiar'),
                          ),
                        ],
                        onChanged: (value) => setState(() => _selectedSource = value!),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Account
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedAccountId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Selecciona una cuenta',
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona una cuenta';
                          }
                          return null;
                        },
                        items: provider.accounts.map((account) {
                          return DropdownMenuItem(
                            value: account.id,
                            child: Text('${account.name} - ${currencyFormat.format(account.balance)}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedAccountId = value),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el monto';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Por favor ingresa un monto válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Comida en restaurante',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Category
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: (_selectedType == TransactionType.expense 
                            ? _expenseCategories 
                            : _incomeCategories).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // IVA Section (only for expenses)
              if (_selectedType == TransactionType.expense) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Información fiscal', style: TextStyle(fontWeight: FontWeight.bold)),
                        SwitchListTile(
                          title: const Text('¿Incluye IVA?'),
                          value: _hasIva,
                          onChanged: (value) {
                            setState(() {
                              _hasIva = value;
                              if (!value) {
                                _isDeductibleIva = false;
                                _selectedUsoCFDI = null;
                              }
                            });
                          },
                        ),
                        if (_hasIva) ...[
                          SwitchListTile(
                            title: const Text('¿IVA Acreditable?'),
                            value: _isDeductibleIva,
                            onChanged: (value) {
                              setState(() {
                                _isDeductibleIva = value;
                                if (!value) {
                                  _selectedUsoCFDI = null;
                                }
                              });
                            },
                          ),
                          if (_isDeductibleIva) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedUsoCFDI,
                              decoration: const InputDecoration(
                                labelText: 'Uso de CFDI',
                                border: OutlineInputBorder(),
                              ),
                              items: _usosCFDI.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text('${entry.key} - ${entry.value}'),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedUsoCFDI = value),
                              validator: (value) {
                                if (_isDeductibleIva && value == null) {
                                  return 'Selecciona el uso de CFDI';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Transacción',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una cuenta'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<FinanceProvider>();
      final amount = double.parse(_amountController.text);

      await provider.addTransaction(
        accountId: _selectedAccountId!,
        description: _descriptionController.text.trim(),
        amount: amount,
        hasIva: _hasIva,
        isDeductibleIva: _isDeductibleIva,
        type: _selectedType,
        source: _selectedSource,
        category: _selectedCategory,
        usoCFDI: _selectedUsoCFDI,
        transactionDate: _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transacción guardada exitosamente'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}