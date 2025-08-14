import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/bank_account_model.dart';
import '../../../theme/bubble_theme.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _interestLimitController = TextEditingController();
  
  String? _selectedInstitution;
  String _selectedType = 'checking';
  Color _selectedColor = Colors.blue;
  bool _hasInterest = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _institutions = [
    {'name': 'BBVA', 'color': Colors.blue},
    {'name': 'Santander', 'color': Colors.red},
    {'name': 'Banamex', 'color': Colors.blue.shade900},
    {'name': 'Banorte', 'color': Colors.red.shade900},
    {'name': 'HSBC', 'color': Colors.red.shade600},
    {'name': 'Scotiabank', 'color': Colors.red.shade700},
    {'name': 'Azteca', 'color': Colors.green.shade700},
    {'name': 'Nu', 'color': Colors.purple},
    {'name': 'Mercado Pago', 'color': Colors.cyan},
    {'name': 'DIDI', 'color': Colors.orange},
    {'name': 'Rappi', 'color': Colors.pink},
    {'name': 'Otro', 'color': Colors.grey},
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _interestRateController.dispose();
    _interestLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final user = authService.currentUser;
      
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final account = BankAccountModel(
        id: '',
        userId: user.uid,
        name: _nameController.text.trim(),
        institution: _selectedInstitution,
        accountType: _selectedType,
        currentBalance: double.parse(_balanceController.text),
        color: _selectedColor.value,
        hasInterest: _hasInterest,
        interestRate: _hasInterest && _interestRateController.text.isNotEmpty
            ? double.parse(_interestRateController.text)
            : null,
        interestRateLimit: _hasInterest && _interestLimitController.text.isNotEmpty
            ? double.parse(_interestLimitController.text)
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .add(account.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear cuenta: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Cuenta'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Básica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la cuenta',
                        hintText: 'Ej: Cuenta Nómina',
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedInstitution,
                      decoration: const InputDecoration(
                        labelText: 'Institución',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      items: _institutions.map((inst) {
                        return DropdownMenuItem<String>(
                          value: inst['name'] as String,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: inst['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(inst['name'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInstitution = value;
                          final institution = _institutions.firstWhere(
                            (inst) => inst['name'] == value,
                          );
                          _selectedColor = institution['color'];
                          
                          // Auto-configurar límites conocidos
                          if (value == 'Nu' || value == 'Mercado Pago') {
                            _interestLimitController.text = '25000';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cuenta',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'checking',
                          child: Text('Cuenta de cheques'),
                        ),
                        DropdownMenuItem(
                          value: 'savings',
                          child: Text('Cuenta de ahorros'),
                        ),
                        DropdownMenuItem(
                          value: 'investment',
                          child: Text('Inversión'),
                        ),
                        DropdownMenuItem(
                          value: 'wallet',
                          child: Text('Billetera digital'),
                        ),
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Tarjeta de crédito'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedType = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Saldo actual',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el saldo';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personalización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Color de la cuenta'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rendimientos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _hasInterest,
                          onChanged: (value) => setState(() => _hasInterest = value),
                          activeColor: BubbleTheme.primaryColor,
                        ),
                      ],
                    ),
                    if (_hasInterest) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _interestRateController,
                        decoration: const InputDecoration(
                          labelText: 'Tasa de interés anual (%)',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.percent),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: _hasInterest
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa la tasa de interés';
                                }
                                final rate = double.tryParse(value);
                                if (rate == null || rate < 0 || rate > 100) {
                                  return 'Ingresa una tasa válida (0-100)';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _interestLimitController,
                        decoration: const InputDecoration(
                          labelText: 'Límite para rendimientos (opcional)',
                          hintText: 'Ej: 25000',
                          helperText: 'Monto máximo sobre el cual aplican rendimientos',
                          prefixIcon: Icon(Icons.trending_up),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                      ),
                      if (_selectedInstitution == 'Nu' || _selectedInstitution == 'Mercado Pago')
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$_selectedInstitution típicamente paga rendimientos solo sobre los primeros \$25,000',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: BubbleTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Crear Cuenta',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}