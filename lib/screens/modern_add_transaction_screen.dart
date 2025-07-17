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
import '../widgets/modern_card.dart';
import '../services/firebase_service.dart';
import 'cfdi_guide_screen.dart';

class ModernAddTransactionScreen extends StatefulWidget {
  const ModernAddTransactionScreen({super.key});

  @override
  State<ModernAddTransactionScreen> createState() => _ModernAddTransactionScreenState();
}

class _ModernAddTransactionScreenState extends State<ModernAddTransactionScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  TransactionType _selectedType = TransactionType.expense;
  int? _selectedAccountId;
  bool _hasIva = false;
  bool _isDeductibleIva = false;
  String? _selectedCategory;
  String? _selectedUsoCFDI;
  DateTime _selectedDate = DateTime.now();
  List<File> _selectedInvoices = [];
  bool _isUploading = false;

  final List<String> _categories = [
    'Alimentos',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Compras',
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
    _descriptionController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Nueva Transacción'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isUploading)
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
              _buildAccountSelector(provider),
              const SizedBox(height: 20),
              _buildDetailsSection(),
              if (_selectedType == TransactionType.expense) ...[
                const SizedBox(height: 20),
                _buildIVASection(),
                if (_isDeductibleIva) ...[
                  const SizedBox(height: 20),
                  _buildInvoiceSection(),
                ],
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

  Widget _buildAccountSelector(FinanceProvider provider) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuenta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedAccountId,
            decoration: const InputDecoration(
              hintText: 'Selecciona una cuenta',
            ),
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona una cuenta';
              }
              return null;
            },
            items: provider.accounts.map((account) {
              final bankColor = _getBankColor(account.bankType);
              return DropdownMenuItem(
                value: account.id,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: bankColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          account.bankType.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: bankColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(account.name),
                          Text(
                            currencyFormat.format(account.balance),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAccountId = value;
              });
            },
          ),
        ],
      ),
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
                });
              },
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Información fiscal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CFDIGuideScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('Ver guía'),
              ),
            ],
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

  Widget _buildInvoiceSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Facturas (CFDI)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_selectedInvoices.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedInvoices.length} archivo${_selectedInvoices.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Archivos seleccionados
          if (_selectedInvoices.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _selectedInvoices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final fileName = file.path.split('/').last;
                  
                  return ListTile(
                    leading: Icon(
                      _getFileIcon(fileName),
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _getFileSize(file),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedInvoices.removeAt(index);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Botones para agregar archivos
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Archivo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
              color: AppTheme.textSecondary,
            ),
          ),
        ],
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
    if (_formKey.currentState!.validate()) {
      final provider = context.read<FinanceProvider>();

      setState(() {
        _isUploading = true;
      });

      try {
        // Primero guardar la transacción
        final transactionId = await provider.addTransaction(
          accountId: _selectedAccountId!,
          description: _descriptionController.text,
          amount: double.parse(_amountController.text),
          hasIva: _hasIva,
          isDeductibleIva: _isDeductibleIva,
          type: _selectedType,
          category: _selectedCategory,
          usoCFDI: _selectedUsoCFDI,
          transactionDate: _selectedDate,
        );

        // Si hay facturas seleccionadas y la transacción es deducible, subirlas
        if (_isDeductibleIva && _selectedInvoices.isNotEmpty && transactionId != null) {
          final firebaseService = FirebaseService();
          final List<String> uploadedUrls = [];

          for (final file in _selectedInvoices) {
            try {
              final fileName = file.path.split('/').last;
              final url = await firebaseService.uploadInvoice(
                file: file,
                transactionId: transactionId,
                fileName: fileName,
              );
              uploadedUrls.add(url);
            } catch (e) {
              print('Error uploading invoice: $e');
            }
          }

          // Actualizar la transacción con las URLs de las facturas
          if (uploadedUrls.isNotEmpty) {
            await provider.updateTransactionInvoices(transactionId, uploadedUrls);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_selectedInvoices.isNotEmpty && _isDeductibleIva
                  ? 'Transacción y facturas guardadas exitosamente'
                  : 'Transacción guardada exitosamente'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
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
            _isUploading = false;
          });
        }
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