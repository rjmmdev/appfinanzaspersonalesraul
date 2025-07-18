import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../data/resico_deductibles.dart';

class CFDIGuideScreen extends StatefulWidget {
  const CFDIGuideScreen({super.key});

  @override
  State<CFDIGuideScreen> createState() => _CFDIGuideScreenState();
}

class _CFDIGuideScreenState extends State<CFDIGuideScreen> {
  String query = '';
  String filter = 'todos';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _results {
    return deductibleExpenses.where((expense) {
      final keywords = expense['keywords'] as List<String>;
      final matchesQuery = query.isEmpty ||
          keywords.any((k) => k.toLowerCase().contains(query.toLowerCase())) ||
          (expense['name'] as String)
              .toLowerCase()
              .contains(query.toLowerCase());
      final matchesFilter = filter == 'todos' ||
          (filter == 'acreditables' && expense['deductible'] == true) ||
          (filter == 'no_acreditables' && expense['deductible'] == false);
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    final List<Widget> children = [
      _buildSearchField(),
      _buildFilterChips(),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text(
          'Resultados: \${results.length}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
      const Divider(height: 16),
    ];

    if (query.isEmpty) {
      children.add(_buildInfoSection());
    }

    if (results.isEmpty) {
      children.add(const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No se encontraron gastos.')),
      ));
    } else {
      for (final expense in results) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _buildResultCard(expense),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía CFDI'),
      ),
      body: ListView(
        children: children,
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Ingresa un gasto (ej. gasolina)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => query = '');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() => query = value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: filter == 'todos',
            onSelected: (_) => setState(() => filter = 'todos'),
          ),
          ChoiceChip(
            label: const Text('Acreditables'),
            selected: filter == 'acreditables',
            onSelected: (_) => setState(() => filter = 'acreditables'),
          ),
          ChoiceChip(
            label: const Text('No acreditables'),
            selected: filter == 'no_acreditables',
            onSelected: (_) => setState(() => filter = 'no_acreditables'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.info_outline,
            title: '¿Qué es el IVA acreditable?',
            content:
                'Es el IVA que pagas en tus compras relacionadas a tu actividad. '
                'Lo recuperas al restarlo del IVA que cobras a tus clientes.',
            color: AppTheme.infoColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.computer,
            title: 'Actividad: Consultor\u00eda en computaci\u00f3n',
            content:
                'La acreditaci\u00f3n aplica a gastos relacionados con servicios de computaci\u00f3n y software.',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.warning_amber_rounded,
            title: 'Requisitos para acreditarlo',
            content:
                '• La factura debe estar a tu nombre y con tu RFC\n'
                '• Debe usar el CFDI correcto y relacionarse con tu negocio\n'
                '• Conserva comprobantes de pago',
            color: AppTheme.warningColor,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> expense) {
    final bool deductible = expense['deductible'] as bool;
    final iconColor =
        deductible ? AppTheme.successColor : AppTheme.errorColor;
    final IconData icon = expense['icon'] as IconData? ?? Icons.receipt_long;
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expense['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      deductible ? Icons.check_circle : Icons.cancel,
                      color: iconColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deductible ? 'Acreditable' : 'No acreditable',
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expense['detail'] as String,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return ModernCard(
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
