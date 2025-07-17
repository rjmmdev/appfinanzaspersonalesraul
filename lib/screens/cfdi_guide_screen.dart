import 'package:flutter/material.dart';

class CFDIGuideScreen extends StatelessWidget {
  const CFDIGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Guía de CFDI para RESICO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (example['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (example['color'] as Color).withValues(alpha: 0.1),
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
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (example['color'] as Color).withValues(alpha: 0.05),
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
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNonDeductibleCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
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