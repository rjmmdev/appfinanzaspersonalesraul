import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import 'deductible_search_screen.dart';

class CFDIGuideScreen extends StatelessWidget {
  const CFDIGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: const Text('Buscar gasto'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeductibleSearchScreen(),
            ),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeductibleSearchScreen(),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration:
                        const BoxDecoration(gradient: AppTheme.primaryGradient),
                  ),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Icon(
                      Icons.receipt_long,
                      size: 160,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Guía de CFDI para RESICO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    context,
                    icon: Icons.info_outline,
                    title: '¿Qué es el IVA acreditable?',
                    content: 'Es el IVA que pagas en tus compras de bienes y servicios para tu actividad empresarial. Este IVA lo puedes recuperar al restarlo del IVA que cobras a tus clientes.',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.warning_amber_rounded,
                    title: 'Requisitos importantes',
                    content: '• La factura debe estar a tu nombre y RFC\n• Debe incluir tu domicilio fiscal correcto\n• El uso de CFDI debe ser el adecuado\n• Solo gastos relacionados con tu actividad',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.people_alt,
                    title: 'Sueldos y prestaciones',
                    content:
                        'Los pagos a empleados no generan IVA acreditable, pero son deducibles de ISR si cumples con las obligaciones de n\u00f3mina.',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.home_repair_service,
                    title: 'Prestaci\u00f3n de servicios',
                    content:
                        'Contratar servicios para tu negocio genera IVA acreditable siempre que cuentes con CFDI y est\u00e9 relacionado con tu actividad.',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    icon: Icons.search,
                    title: 'Busca un gasto',
                    content:
                        'Toca el icono de la lupa en la esquina superior para saber si un gasto es acreditable.',
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ejemplos de gastos deducibles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildDeductibleExamples(context),
                  const SizedBox(height: 24),
                  Text(
                    'Gastos NO deducibles',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNonDeductibleCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 10,
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
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDeductibleExamples(BuildContext context) {
    final examples = [
      {
        'usoCFDI': 'G03',
        'title': 'Gastos en general',
        'icon': Icons.receipt_long,
        'color': Colors.purple,
        'examples': [
          '• Comida de negocio en restaurante (\$520)',
          '• Uber para visitar cliente (\$180)',
          '• Papelería de oficina (\$340)',
          '• Servicios de mensajería (\$150)',
        ],
      },
      {
        'usoCFDI': 'I04',
        'title': 'Equipo de cómputo',
        'icon': Icons.computer,
        'color': Colors.blue,
        'examples': [
          '• Laptop HP para trabajo (\$18,500)',
          '• Mouse y teclado (\$1,200)',
          '• Monitor externo (\$4,800)',
          '• Disco duro externo (\$1,500)',
        ],
      },
      {
        'usoCFDI': 'I06',
        'title': 'Comunicaciones telefónicas',
        'icon': Icons.phone_android,
        'color': Colors.green,
        'examples': [
          '• Plan de celular Telcel (\$599/mes)',
          '• Internet de fibra óptica (\$789/mes)',
          '• Teléfono fijo de oficina (\$350/mes)',
        ],
      },
      {
        'usoCFDI': 'I03',
        'title': 'Equipo de transporte',
        'icon': Icons.directions_car,
        'color': Colors.orange,
        'examples': [
          '• Gasolina para auto de trabajo (\$2,500/mes)',
          '• Servicio y mantenimiento (\$3,200)',
          '• Seguro de auto (\$15,000/año)',
          '• Verificación vehicular (\$580)',
        ],
      },
      {
        'usoCFDI': 'G01',
        'title': 'Adquisición de mercancías',
        'icon': Icons.shopping_cart,
        'color': Colors.teal,
        'examples': [
          '• Compra de productos para reventa',
          '• Materiales para producción',
          '• Insumos para servicios',
          '• Inventario de mercancía',
        ],
      },
      {
        'usoCFDI': 'I02',
        'title': 'Mobiliario y equipo de oficina',
        'icon': Icons.chair,
        'color': Colors.indigo,
        'examples': [
          '• Escritorio de trabajo (\$4,500)',
          '• Silla ergonómica (\$3,200)',
          '• Archivero (\$2,100)',
          '• Lámpara de escritorio (\$850)',
        ],
      },
    ];

    return examples.map((example) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ModernCard(
          border: Border.all(
            color: (example['color'] as Color).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (example['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  example['icon'] as IconData,
                  color: example['color'] as Color,
                ),
              ),
              title: Text(
                example['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Uso CFDI: ${example['usoCFDI']}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (example['color'] as Color).withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ejemplos de facturas:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(example['examples'] as List<String>).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: example['color'] as Color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNonDeductibleCard(BuildContext context) {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      color: Colors.red[50],
      border: Border.all(
        color: Colors.red.withOpacity(0.3),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Estos gastos NO son deducibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...[
            '• Gastos personales (ropa, entretenimiento personal)',
            '• Multas y recargos',
            '• Gastos sin factura o con factura incorrecta',
            '• Compras en el supermercado para casa',
            '• Gastos médicos personales (usa D01 para deducción personal)',
            '• Viajes de placer',
            '• Regalos personales',
            '• Gastos de tarjeta de crédito personal',
          ].map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          ],
      ),
    );
  }
}