import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

class CompatibleTransactionScreen extends StatefulWidget {
  const CompatibleTransactionScreen({super.key});

  @override
  State<CompatibleTransactionScreen> createState() => _CompatibleTransactionScreenState();
}

class _CompatibleTransactionScreenState extends State<CompatibleTransactionScreen> {
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
  SatDebtType _satDebtType = SatDebtType.none;
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
    'Deuda SAT',
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount Section - Prominent
                _buildAmountCard(),
                const SizedBox(height: 16),
                
                // Transaction Type
                _buildTransactionTypeCard(),
                const SizedBox(height: 16),
                
                // Money Source
                _buildMoneySourceCard(),
                const SizedBox(height: 16),
                
                // Account Selection
                _buildAccountCard(provider),
                const SizedBox(height: 16),
                
                // Description
                _buildDescriptionCard(),
                const SizedBox(height: 16),
                
                // Category
                _buildCategoryCard(),
                const SizedBox(height: 16),
                
                // Date
                _buildDateCard(),
                
                // IVA Section (only for expenses)
                if (_selectedType == TransactionType.expense) ...[
                  const SizedBox(height: 16),
                  _buildIVACard(),
                ],
                
                const SizedBox(height: 24),
                
                // Save Button
                _buildSaveButton(),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final amountColor = _selectedType == TransactionType.income
        ? Colors.green
        : _selectedType == TransactionType.satDebt
            ? Colors.orange
            : Colors.red;
        
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: amountColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Monto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: amountColor.withOpacity(0.7),
                ),
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
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
              onChanged: (_) => setState(() {}),
            ),
            if (_hasIva && _amountController.text.isNotEmpty) ...[
              const Divider(),
              _buildIVABreakdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIVABreakdown() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final subtotal = amount / 1.16;
    final iva = amount - subtotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: TextStyle(color: Colors.grey[600])),
              Text(currencyFormat.format(subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IVA (16%):', style: TextStyle(color: Colors.grey[600])),
              Text(currencyFormat.format(iva), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de transacción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    type: TransactionType.income,
                    label: 'Ingreso',
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    type: TransactionType.expense,
                    label: 'Gasto',
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    type: TransactionType.satDebt,
                    label: 'Deuda SAT',
                    icon: Icons.gavel,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneySourceCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuente del dinero',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    source: MoneySource.personal,
                    label: 'Personal',
                    icon: Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSourceButton(
                    source: MoneySource.work,
                    label: 'Trabajo',
                    icon: Icons.work,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSourceButton(
                    source: MoneySource.family,
                    label: 'Familiar',
                    icon: Icons.family_restroom,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required MoneySource source,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedSource == source;
    
    return InkWell(
      onTap: () => setState(() => _selectedSource = source),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(FinanceProvider provider) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cuenta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedAccountId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Selecciona una cuenta',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una cuenta';
                }
                return null;
              },
              items: provider.accounts.map((account) {
                final bankColor = _getBankColor(account.bankType);
                final isCredit = account.accountType == AccountType.credit;
                
                return DropdownMenuItem(
                  value: account.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bankColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            account.bankType.name.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              color: bankColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  account.name,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCredit ? Colors.red[50] : Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isCredit ? 'Crédito' : 'Débito',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCredit ? Colors.red[700] : Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currencyFormat.format(account.balance),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAccountId = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
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
    );
  }

  Widget _buildCategoryCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedType != TransactionType.satDebt) ...[
              Text(
                'Categoría',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: (_selectedType == TransactionType.expense
                        ? _expenseCategories
                        : _incomeCategories)
                    .map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                      _selectedCategory = value;
                      if (value != 'Deuda SAT') {
                        _satDebtType = SatDebtType.none;
                      }
                    }),
              ),
              if (_selectedCategory == 'Deuda SAT') ...[
                const SizedBox(height: 12),
                _buildSatDebtDropdown(),
              ],
            ] else ...[
              Text(
                'Tipo de Deuda SAT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              _buildSatDebtDropdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSatDebtDropdown() {
    return DropdownButtonFormField<SatDebtType>(
      value: _satDebtType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: SatDebtType.iva,
          child: Text('IVA'),
        ),
        DropdownMenuItem(
          value: SatDebtType.isr,
          child: Text('ISR'),
        ),
      ],
      onChanged: (value) => setState(() => _satDebtType = value ?? SatDebtType.none),
      validator: (value) {
        if (value == null || value == SatDebtType.none) {
          return 'Selecciona el tipo de deuda';
        }
        return null;
      },
    );
  }

  Widget _buildDateCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'es_MX').format(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIVACard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Información fiscal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                title: const Text('¿Incluye IVA?'),
                subtitle: const Text('El monto incluye 16% de IVA', style: TextStyle(fontSize: 12)),
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
                activeColor: AppTheme.primaryColor,
              ),
            ),
            if (_hasIva) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  title: const Text('¿IVA Acreditable?'),
                  subtitle: const Text('Para deducciones RESICO', style: TextStyle(fontSize: 12)),
                  value: _isDeductibleIva,
                  onChanged: (value) {
                    setState(() {
                      _isDeductibleIva = value;
                      if (!value) {
                        _selectedUsoCFDI = null;
                      }
                    });
                  },
                  activeColor: Colors.blue[700],
                ),
              ),
              if (_isDeductibleIva) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedUsoCFDI,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Uso de CFDI',
                    labelStyle: const TextStyle(fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _usosCFDI.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(
                        '${entry.key} - ${entry.value}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
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
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.save, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Guardar Transacción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == TransactionType.satDebt &&
        _satDebtType == SatDebtType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona si la deuda es de IVA o ISR'),
          backgroundColor: Colors.red,
        ),
      );
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
        satDebtType: _satDebtType,
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