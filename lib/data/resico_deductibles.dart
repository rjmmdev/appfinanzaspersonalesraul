import 'package:flutter/material.dart';

const List<Map<String, dynamic>> deductibleExpenses = [
  {
    'name': 'Comida de negocio',
    'keywords': ['comida', 'restaurante', 'alimentos'],
    'deductible': true,
    'icon': Icons.restaurant,
    'detail':
        'Deducible cuando sea con fines de negocio y cuentes con CFDI de restaurante con uso G03.'
  },
  {
    'name': 'Compras personales de supermercado',
    'keywords': ['supermercado', 'compras para casa', 'despensa'],
    'deductible': false,
    'icon': Icons.shopping_cart,
    'detail':
        'Gastos familiares o personales no se consideran acreditables para RESICO.'
  },
  {
    'name': 'Gasolina para actividades',
    'keywords': ['gasolina', 'combustible'],
    'deductible': true,
    'icon': Icons.local_gas_station,
    'detail':
        'El combustible utilizado para el negocio es deducible con CFDI y forma de pago registrada.'
  },
  {
    'name': 'Ropa personal',
    'keywords': ['ropa', 'zapatos'],
    'deductible': false,
    'icon': Icons.checkroom,
    'detail': 'La ropa de uso personal no es un gasto acreditable.'
  },
  {
    'name': 'Hospedaje y vi\u00e1ticos de trabajo',
    'keywords': ['hospedaje', 'vi\u00e1ticos', 'hotel'],
    'deductible': true,
    'icon': Icons.hotel,
    'detail':
        'Siempre que el viaje sea de negocios relacionado con consultor\u00eda en computaci\u00f3n y cuentes con CFDI correcto.'
  },
  {
    'name': 'Equipo de c\u00f3mputo',
    'keywords': ['laptop', 'computadora', 'equipo de c\u00f3mputo'],
    'deductible': true,
    'icon': Icons.computer,
    'detail':
        'Computadoras y accesorios utilizados en tu actividad econ\u00f3mica con CFDI I04.'
  },
  {
    'name': 'Software y licencias',
    'keywords': ['software', 'licencias', 'suscripciones', 'programas'],
    'deductible': true,
    'icon': Icons.developer_mode,
    'detail':
        'Herramientas de software y licencias necesarias para la consultor\u00eda en computaci\u00f3n con CFDI I04 o I08.'
  },
  {
    'name': 'Multas y recargos',
    'keywords': ['multas', 'recargos'],
    'deductible': false,
    'icon': Icons.gavel,
    'detail': 'Pagos de sanciones o recargos no son deducibles.'
  },
  {
    'name': 'Publicidad y marketing',
    'keywords': ['publicidad', 'marketing', 'anuncios'],
    'deductible': true,
    'icon': Icons.campaign,
    'detail': 'Gastos de promoci\u00f3n con factura a tu nombre.'
  },
  {
    'name': 'Servicios de comunicaci\u00f3n',
    'keywords': ['internet', 'celular', 'telefon\u00eda'],
    'deductible': true,
    'icon': Icons.phone,
    'detail':
        'Planes de telefon\u00eda e internet utilizados para consultor\u00eda en computaci\u00f3n con CFDI I06.'
  },
  {
    'name': 'Entretenimiento personal',
    'keywords': ['cine', 'ocio', 'entretenimiento'],
    'deductible': false,
    'icon': Icons.movie,
    'detail': 'Diversi\u00f3n personal no es acreditable ante el SAT.'
  },
  {
    'name': 'Sueldos y prestaciones a empleados',
    'keywords': ['sueldos', 'salarios', 'n\u00f3mina', 'prestaciones'],
    'deductible': false,
    'icon': Icons.people,
    'detail':
        'Los pagos de n\u00f3mina y prestaciones sociales no generan IVA acreditable, aunque son deducibles de ISR si se cumplen los requisitos fiscales.'
  },
  {
    'name': 'Prestaci\u00f3n de servicios a terceros',
    'keywords': ['servicios', 'honorarios', 'prestaci\u00f3n de servicios'],
    'deductible': true,
    'icon': Icons.handshake,
    'detail':
        'Los servicios contratados para tu actividad (consultor\u00eda, mantenimiento, etc.) generan IVA acreditable siempre que cuentes con CFDI y se relacionen con el negocio.'
  },
  {
    'name': 'Transporte p\u00fablico por trabajo',
    'keywords': ['transporte', 'bus', 'taxi'],
    'deductible': true,
    'icon': Icons.directions_bus,
    'detail': 'Gastos de transporte cuando son necesarios para tu actividad y cuentes con CFDI.'
  },
  {
    'name': 'Arrendamiento de oficina',
    'keywords': ['renta', 'oficina'],
    'deductible': true,
    'icon': Icons.business,
    'detail': 'La renta de un espacio destinado a tu actividad es acreditable con CFDI.'
  },
  {
    'name': 'Mantenimiento de oficina',
    'keywords': ['mantenimiento', 'reparaciones'],
    'deductible': true,
    'icon': Icons.build,
    'detail': 'Reparaciones y mantenimiento del lugar de trabajo con factura son acreditables.'
  },
  {
    'name': 'Material de oficina',
    'keywords': ['papeler\u00eda', 'oficina'],
    'deductible': true,
    'icon': Icons.receipt,
    'detail': 'Art\u00edculos de papeler\u00eda y materiales utilizados en el negocio.'
  },
  {
    'name': 'Servicios de limpieza',
    'keywords': ['limpieza', 'aseo'],
    'deductible': true,
    'icon': Icons.cleaning_services,
    'detail': 'Gastos de limpieza para el \u00e1rea de trabajo con CFDI.'
  },
  {
    'name': 'Seguros de responsabilidad',
    'keywords': ['seguros', 'responsabilidad'],
    'deductible': true,
    'icon': Icons.verified_user,
    'detail': 'P\u00f3lizas relacionadas con la actividad pueden acreditarse con CFDI.'
  },
  {
    'name': 'Cursos y capacitaci\u00f3n',
    'keywords': ['cursos', 'capacitacion', 'formaci\u00f3n'],
    'deductible': true,
    'icon': Icons.school,
    'detail': 'Formaci\u00f3n y actualizaci\u00f3n profesional relacionada con tu actividad.'
  },
  {
    'name': 'Suscripciones profesionales',
    'keywords': ['suscripciones', 'revistas', 'software'],
    'deductible': true,
    'icon': Icons.subscriptions,
    'detail': 'Suscripciones de uso profesional con CFDI v\u00e1lido.'
  },
  {
    'name': 'Honorarios contables',
    'keywords': ['contabilidad', 'impuestos'],
    'deductible': true,
    'icon': Icons.calculate,
    'detail': 'Servicios de contabilidad y asesor\u00eda fiscal con CFDI I01.'
  },
  {
    'name': 'Mobiliario de oficina',
    'keywords': ['muebles', 'escritorio'],
    'deductible': true,
    'icon': Icons.chair,
    'detail': 'Muebles y equipo menor utilizados en el \u00e1rea de trabajo con CFDI I04.'
  },
  {
    'name': 'Pagos de luz y agua',
    'keywords': ['electricidad', 'agua'],
    'deductible': true,
    'icon': Icons.lightbulb,
    'detail': 'Servicios b\u00e1sicos del lugar de trabajo con comprobante fiscal.'
  },
  {
    'name': 'Herramientas y equipo',
    'keywords': ['herramientas', 'equipo menor'],
    'deductible': true,
    'icon': Icons.construction,
    'detail': 'Herramientas necesarias para la actividad econ\u00f3mica con CFDI.'
  },
  {
    'name': 'Mensajer\u00eda y paqueter\u00eda',
    'keywords': ['env\u00edo', 'paqueter\u00eda'],
    'deductible': true,
    'icon': Icons.local_shipping,
    'detail': 'Costos de env\u00edo de documentos o mercanc\u00edas relacionados al negocio.'
  },
  {
    'name': 'Regalos a clientes',
    'keywords': ['regalos', 'clientes'],
    'deductible': false,
    'icon': Icons.card_giftcard,
    'detail': 'Obsequios ocasionales que no cumplen requisitos para deducir IVA.'
  },
];
