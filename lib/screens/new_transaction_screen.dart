import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
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
  List<File> _selectedInvoices = [];
  bool _isLoading = false;

  // Categories
  final List<String> _expenseCategories = [
    'Alimentos',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Compras',
    'Otros',
  ];

  final List<String> _incomeCategories = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Ventas',
    'Regalos',
    'Reembolsos',
    'Intereses',
    'Otros',
  ];

  // CFDI usage codes for RESICO
  final Map<String, String> _usosCFDI = {
    'G01': 'Adquisición de mercancías',
    'G03': 'Gastos en general',
    'I01': 'Construcciones',
    'I03': 'Equipo de transporte',
    'I04': 'Equipo de cómputo y accesorios',
    'D01': 'Honorarios médicos, dentales y gastos hospitalarios',
    'D04': 'Donativos',
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Transaction Type Selector
                  _buildTransactionTypeSelector(),
                  const SizedBox(height: 20),
                  
                  // Money Source Selector
                  _buildMoneySourceSelector(),
                  const SizedBox(height: 20),
                  
                  // Account Selector
                  _buildAccountSelector(provider),
                  const SizedBox(height: 20),
                  
                  // Amount Input
                  _buildAmountField(),
                  const SizedBox(height: 20),
                  
                  // Description Field
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  
                  // Category Selector
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  
                  // Date Selector
                  _buildDateSelector(),
                  
                  // IVA Section (only for expenses)
                  if (_selectedType == TransactionType.expense) ...[
                    const SizedBox(height: 20),
                    _buildIVASection(),
                  ],
                  
                  // Invoice Section (only for deductible expenses)
                  if (_selectedType == TransactionType.expense && _isDeductibleIva) ...[
                    const SizedBox(height: 20),
                    _buildInvoiceSection(),
                  ],
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.income,
              label: 'Ingreso',
              icon: Icons.arrow_downward_rounded,
              color: AppTheme.successColor,
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              type: TransactionType.expense,
              label: 'Gasto',
              icon: Icons.arrow_upward_rounded,
              color: AppTheme.errorColor,
            ),
          ),
        ],
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
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategory = null;
          if (type != TransactionType.expense) {
            _hasIva = false;
            _isDeductibleIva = false;
            _selectedUsoCFDI = null;
            _selectedInvoices.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : [],
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

  Widget _buildMoneySourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fuente del dinero',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSourceChip(
                source: MoneySource.personal,
                label: 'Personal',
                icon: Icons.person_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSourceChip(
                source: MoneySource.work,
                label: 'Trabajo',
                icon: Icons.work_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSourceChip(
                source: MoneySource.family,
                label: 'Familiar',
                icon: Icons.family_restroom_rounded,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceChip({
    required MoneySource source,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedSource == source;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedSource = source),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(FinanceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuenta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedAccountId,
          decoration: InputDecoration(
            hintText: 'Selecciona una cuenta',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
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
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bankColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        account.bankType.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: bankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              account.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
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
                          currencyFormat.format(account.balance),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            hintText: '0.00',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: _buildIVABreakdown(),
          ),
        ],
      ],
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
            const Text('Subtotal:', style: TextStyle(fontSize: 14)),
            Text(
              currencyFormat.format(subtotal),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('IVA (16%):', style: TextStyle(fontSize: 14)),
            Text(
              currencyFormat.format(iva),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Ej: Comida en restaurante',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor ingresa una descripción';
            }
            if (value.trim().length < 3) {
              return 'La descripción debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = _selectedType == TransactionType.expense 
        ? _expenseCategories 
        : _incomeCategories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1) 
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, 
                    size: 20, 
                    color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'es_MX').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIVASection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información fiscal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
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
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
          ),
          if (_hasIva) ...[
            const Divider(),
            SwitchListTile(
              title: const Text('¿IVA Acreditable?'),
              subtitle: const Text('Para deducciones RESICO'),
              value: _isDeductibleIva,
              onChanged: (value) {
                setState(() {
                  _isDeductibleIva = value;
                  if (!value) {
                    _selectedUsoCFDI = null;
                    _selectedInvoices.clear();
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primaryColor,
            ),
            if (_isDeductibleIva) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUsoCFDI,
                decoration: InputDecoration(
                  labelText: 'Uso de CFDI',
                  helperText: 'Requerido para gastos deducibles',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
    );
  }

  Widget _buildInvoiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Facturas (CFDI)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (_selectedInvoices.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedInvoices.length} archivo(s)',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Selected files
          if (_selectedInvoices.isNotEmpty) ...[
            ...List.generate(_selectedInvoices.length, (index) {
              final file = _selectedInvoices[index];
              final fileName = file.path.split('/').last;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(fileName),
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getFileSize(file),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedInvoices.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          
          // Add file buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Archivo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Formatos: PDF, XML, JPG, PNG (máx. 10MB)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Guardar Transacción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xml', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        final files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .where((file) => file.lengthSync() <= 10 * 1024 * 1024) // 10MB max
            .toList();

        if (files.length < result.paths.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Algunos archivos exceden el límite de 10MB'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }

        setState(() {
          _selectedInvoices.addAll(files);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final file = File(photo.path);
        if (file.lengthSync() <= 10 * 1024 * 1024) {
          setState(() {
            _selectedInvoices.add(file);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('La imagen excede el límite de 10MB'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'xml':
        return Icons.code;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

    if (_isDeductibleIva && _selectedUsoCFDI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona el uso de CFDI'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<FinanceProvider>();
      final amount = double.parse(_amountController.text);

      // Save transaction
      final transactionId = await provider.addTransaction(
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

      print('Transaction saved with ID: $transactionId');

      // Upload invoices if any
      if (_isDeductibleIva && _selectedInvoices.isNotEmpty && transactionId != null) {
        final firebaseService = FirebaseService();
        final List<String> uploadedUrls = [];

        for (int i = 0; i < _selectedInvoices.length; i++) {
          final file = _selectedInvoices[i];
          try {
            final fileName = file.path.split('/').last;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final uniqueFileName = '${timestamp}_${i}_$fileName';
            
            print('Uploading invoice: $uniqueFileName');
            
            final url = await firebaseService.uploadInvoice(
              file: file,
              transactionId: transactionId,
              fileName: uniqueFileName,
            );
            uploadedUrls.add(url);
            print('Invoice uploaded successfully: $url');
          } catch (e) {
            print('Error uploading invoice ${file.path}: $e');
          }
        }

        // Update transaction with invoice URLs
        if (uploadedUrls.isNotEmpty) {
          print('Updating transaction with ${uploadedUrls.length} invoice URLs');
          await provider.updateTransactionInvoices(transactionId, uploadedUrls);
        }
      }

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
      print('Error saving transaction: $e');
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