# Configuración Firebase Only

## ✅ Cambios realizados:

1. **Eliminé completamente SQLite**
   - Removí DatabaseService
   - Removí SyncService
   - Removí LocalOnlyService
   - Comenté la dependencia sqflite en pubspec.yaml

2. **FirebaseService es ahora el único servicio de datos**
   - Todas las operaciones CRUD van directo a Firestore
   - No hay caché local
   - No hay sincronización - todo es en tiempo real

3. **Manejo de IDs mejorado**
   - Firebase usa IDs string, pero los modelos usan int
   - Creé un sistema de mapeo interno que convierte entre ambos
   - Los IDs numéricos se generan con hashCode

## 🔥 Requisitos para que funcione:

### 1. Firestore DEBE estar habilitado:
- Ve a https://console.firebase.google.com/
- Selecciona tu proyecto "finanzaspersonalesraul"
- Click en "Firestore Database"
- Click en "Crear base de datos"
- Selecciona modo de prueba
- Selecciona ubicación (us-central1)
- Click en "Habilitar"

### 2. Reglas de Firestore (temporales para pruebas):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 3. Limpia y reconstruye:
```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Cómo probar:

1. **Abre la app**
2. **Ve a "Gestionar Cuentas"**
3. **Agrega una nueva cuenta** con el botón +
4. **Toca el botón de actualizar** (↻)
5. **La cuenta debería aparecer**

## 📊 Verificar en Firebase Console:

1. Ve a Firestore Database en la consola
2. Deberías ver la colección "accounts"
3. Dentro verás los documentos de las cuentas creadas

## ⚠️ Importante:

- **La app NO funcionará sin conexión a internet**
- **Firestore DEBE estar habilitado**
- **Las reglas deben permitir lectura/escritura**

## 🐛 Debugging:

Si ves errores como:
- "PERMISSION_DENIED": Las reglas de Firestore no permiten acceso
- "Cloud Firestore API has not been used": Firestore no está habilitado
- Cuentas no aparecen: Verifica en la consola de Firebase si se crearon

En los logs deberías ver:
```
Loaded X accounts from Firebase
Error loading accounts from Firebase: [solo si hay problemas]
```