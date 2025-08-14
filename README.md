# Bubble - Personal Finance Management App

Una aplicación móvil para gestión de finanzas personales con soporte para múltiples cuentas bancarias y cálculo inteligente de rendimientos.

## Características

- 🔐 **Autenticación segura** con Firebase Auth
- 💳 **Gestión de múltiples cuentas bancarias**
- 📈 **Cálculo inteligente de rendimientos** con límites configurables
- 🎨 **Interfaz moderna** con diseño Material Design 3
- 📱 **Multiplataforma**: iOS, Android y Web
- 🔄 **Sincronización en tiempo real** con Firebase Firestore

## Requisitos

- Flutter 3.8.1 o superior
- Dart SDK
- Cuenta de Firebase con proyecto configurado
- Android Studio / Xcode (para desarrollo móvil)

## Instalación

1. Clona el repositorio:
```bash
git clone [URL_DEL_REPOSITORIO]
cd finanzaspersonales
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura Firebase:
   - Asegúrate de tener configurado `android/app/google-services.json` para Android
   - Asegúrate de tener configurado `ios/Runner/GoogleService-Info.plist` para iOS
   - El archivo `lib/firebase_options.dart` ya está configurado

4. Ejecuta la aplicación:
```bash
# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para Web
flutter run -d chrome
```

## Estructura del Proyecto

```
lib/
├── data/
│   ├── models/          # Modelos de datos
│   └── services/         # Servicios (Auth, Firebase)
├── presentation/
│   ├── screens/          # Pantallas de la app
│   └── widgets/          # Widgets reutilizables
└── theme/                # Configuración de temas
```

## Funcionalidades Principales

### Gestión de Cuentas
- Crear cuentas con nombre personalizado
- Asignar colores para identificación visual
- Configurar institución bancaria
- Establecer tasas de interés y límites

### Cálculo de Rendimientos
- Soporte para límites de rendimiento (ej: Nu y Mercado Pago solo pagan interés sobre los primeros $25,000)
- Cálculo automático de interés diario, mensual y anual
- Visualización clara de rendimientos proyectados

### Dashboard
- Vista general de todas las cuentas
- Balance total consolidado
- Acciones rápidas para ingresos y gastos
- Resumen de movimientos recientes

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Firebase Auth**: Autenticación de usuarios
- **Cloud Firestore**: Base de datos en tiempo real
- **Material Design 3**: Sistema de diseño

## Contribuir

Este es un proyecto personal, pero las sugerencias son bienvenidas a través de issues.

## Licencia

Proyecto privado - Todos los derechos reservados