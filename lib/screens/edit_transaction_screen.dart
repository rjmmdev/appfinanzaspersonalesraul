import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  
  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  TransactionType _selectedType = TransactionType.expense;
  bool _hasIva = false;
  bool _isDeductibleIva = false;
  SatDebtType _satDebtType = SatDebtType.none;
  String? _selectedCategory;
  String? _selectedUsoCFDI;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Alimentos',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Compras',
    'Deuda SAT',
    'Otros',
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
    'D07': 'Primas por seguros de gastos médicos',
    'D08': 'Gastos de transportación escolar obligatoria',
    'D10': 'Pagos por servicios educativos (colegiaturas)',
    'S01': 'Sin efectos fiscales',
  };

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con valores de la transacción
    _descriptionController.text = widget.transaction.description;
    _amountController.text = widget.transaction.amount.toString();
    _selectedType = widget.transaction.type;
    _hasIva = widget.transaction.hasIva;
    _isDeductibleIva = widget.transaction.isDeductibleIva;
    _selectedCategory = widget.transaction.category;
    _satDebtType = widget.transaction.satDebtType;
    _selectedUsoCFDI = widget.transaction.usoCFDI;
    _selectedDate = widget.transaction.transactionDate;
    
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

  Widget _buildSatDebtDropdown() {
    return DropdownButtonFormField<SatDebtType>(
      value: _satDebtType == SatDebtType.none ? null : _satDebtType,
      decoration: const InputDecoration(
        labelText: 'Tipo de Deuda SAT',
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
      onChanged: (value) {
        setState(() {
          _satDebtType = value ?? SatDebtType.none;
        });
      },
      validator: (value) {
        if (_selectedType == TransactionType.satDebt &&
            (value == null || value == SatDebtType.none)) {
          return 'Selecciona el tipo de deuda';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Editar Transacción'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveTransaction,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTransactionTypeSelector(),
              const SizedBox(height: 20),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildDetailsSection(),
              if (_selectedType == TransactionType.expense) ...[
                const SizedBox(height: 20),
                _buildIVASection(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return ModernCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              icon: Icons.arrow_downward,
              label: 'Ingreso',
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              icon: Icons.arrow_upward,
              label: 'Gasto',
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type != TransactionType.expense) {
              _hasIva = false;
              _isDeductibleIva = false;
              _selectedUsoCFDI = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monto',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
              hintText: '0.00',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
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
            const Divider(height: 32),
            _buildIVABreakdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildIVABreakdown() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final subtotal = amount / 1.16;
    final iva = amount - subtotal;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              currencyFormat.format(subtotal),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'IVA (16%)',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              currencyFormat.format(iva),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Ej: Comida en restaurante',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (_selectedType == TransactionType.expense) ...[
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  if (value != 'Deuda SAT') {
                    _satDebtType = SatDebtType.none;
                  }
                });
              },
            ),
            if (_selectedCategory == 'Deuda SAT') ...[
              const SizedBox(height: 16),
              _buildSatDebtDropdown(),
            ],
            const SizedBox(height: 16),
          ] else if (_selectedType == TransactionType.satDebt) ...[
            _buildSatDebtDropdown(),
            const SizedBox(height: 16),
          ],
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIVASection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información fiscal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('¿Incluye IVA?'),
              subtitle: const Text('El monto incluye 16% de IVA'),
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
          ),
          if (_hasIva) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: SwitchListTile(
                title: const Text('¿IVA Acreditable?'),
                subtitle: const Text('Para deducciones RESICO'),
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
            ),
          ],
          if (_hasIva && _isDeductibleIva) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUsoCFDI,
              decoration: const InputDecoration(
                labelText: 'Uso de CFDI',
                helperText: 'Requerido para gastos deducibles',
              ),
              isExpanded: true,
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
              onChanged: (value) {
                setState(() {
                  _selectedUsoCFDI = value;
                });
              },
              validator: (value) {
                if (_isDeductibleIva && value == null) {
                  return 'Por favor selecciona el uso de CFDI';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
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
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = context.read<FinanceProvider>();
        await provider.updateTransaction(
          transactionId: widget.transaction.id!,
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          hasIva: _hasIva,
          isDeductibleIva: _isDeductibleIva,
          type: _selectedType,
          source: widget.transaction.source,
          satDebtType: _satDebtType,
          category: _selectedCategory,
          usoCFDI: _selectedUsoCFDI,
          transactionDate: _selectedDate,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transacción actualizada exitosamente'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}