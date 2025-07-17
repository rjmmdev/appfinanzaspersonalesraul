const List<Map<String, dynamic>> deductibleExpenses = [
  {
    'name': 'Comida de negocio',
    'keywords': ['comida', 'restaurante', 'alimentos'],
    'deductible': true,
    'detail':
        'Deducible cuando sea con fines de negocio y cuentes con CFDI de restaurante con uso G03.'
  },
  {
    'name': 'Compras personales de supermercado',
    'keywords': ['supermercado', 'compras para casa', 'despensa'],
    'deductible': false,
    'detail':
        'Gastos familiares o personales no se consideran acreditables para RESICO.'
  },
  {
    'name': 'Gasolina para actividades',
    'keywords': ['gasolina', 'combustible'],
    'deductible': true,
    'detail':
        'El combustible utilizado para el negocio es deducible con CFDI y forma de pago registrada.'
  },
  {
    'name': 'Ropa personal',
    'keywords': ['ropa', 'zapatos'],
    'deductible': false,
    'detail': 'La ropa de uso personal no es un gasto acreditable.'
  },
  {
    'name': 'Hospedaje y vi\u00e1ticos de trabajo',
    'keywords': ['hospedaje', 'vi\u00e1ticos', 'hotel'],
    'deductible': true,
    'detail':
        'Siempre que el viaje sea de negocios y cuentes con CFDI correcto.'
  },
  {
    'name': 'Equipo de c\u00f3mputo',
    'keywords': ['laptop', 'computadora', 'equipo de c\u00f3mputo'],
    'deductible': true,
    'detail':
        'Computadoras y accesorios utilizados en tu actividad econ\u00f3mica con CFDI I04.'
  },
  {
    'name': 'Multas y recargos',
    'keywords': ['multas', 'recargos'],
    'deductible': false,
    'detail': 'Pagos de sanciones o recargos no son deducibles.'
  },
  {
    'name': 'Publicidad y marketing',
    'keywords': ['publicidad', 'marketing', 'anuncios'],
    'deductible': true,
    'detail': 'Gastos de promoci\u00f3n con factura a tu nombre.'
  },
  {
    'name': 'Servicios de comunicaci\u00f3n',
    'keywords': ['internet', 'celular', 'telefon\u00eda'],
    'deductible': true,
    'detail':
        'Planes de telefon\u00eda e internet utilizados para el negocio con CFDI I06.'
  },
  {
    'name': 'Entretenimiento personal',
    'keywords': ['cine', 'ocio', 'entretenimiento'],
    'deductible': false,
    'detail': 'Diversi\u00f3n personal no es acreditable ante el SAT.'
  },
];
