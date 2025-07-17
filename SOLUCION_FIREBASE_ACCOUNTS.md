# Solución: Cargar cuentas desde Firebase

## ✅ Cambios realizados:

1. **Eliminé SQLite completamente**
   - La app ahora usa SOLO Firebase Firestore
   - No hay base de datos local

2. **Agregué logs detallados**
   - FirebaseService ahora imprime cuántos documentos encuentra
   - FinanceProvider muestra qué cuentas se cargan

3. **Simplifiqué las consultas**
   - Eliminé orderBy para evitar problemas de índices
   - Las consultas ahora son más directas

## 🔧 Pasos para solucionar:

### 1. Limpia y reconstruye completamente:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Verifica la consola de Firebase:
- Ve a https://console.firebase.google.com/
- Proyecto: finanzaspersonalesraul
- Firestore Database → accounts
- Verifica que existan documentos

### 3. Verifica las reglas de Firestore:
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

### 4. En la app:
1. Abre "Gestionar Cuentas"
2. Toca el botón actualizar (↻)
3. Revisa los logs

## 📊 Logs esperados:

Deberías ver algo como:
```
FirebaseService: Fetching accounts from Firestore...
FirebaseService: Found 1 documents in accounts collection
FirebaseService: Processing document [ID]
FirebaseService: Document data: {name: ..., bankType: ..., ...}
FirebaseService: Successfully loaded 1 accounts
FinanceProvider: Loading accounts from Firebase...
FinanceProvider: Loaded 1 accounts from Firebase
  - Account: [nombre] ([banco]) - Balance: [balance]
```

## 🐛 Si aún no funciona:

### Verifica en Firebase Console:
1. ¿La colección se llama exactamente "accounts"?
2. ¿Los documentos tienen los campos correctos?
   - name (String)
   - bankType (String)
   - balance (Number)
   - annualInterestRate (Number)
   - createdAt (Timestamp o String)
   - updatedAt (Timestamp o String)

### Posibles errores:
- Si dice "Found 0 documents": La colección está vacía o mal nombrada
- Si hay error de parsing: Los tipos de datos no coinciden
- Si hay PERMISSION_DENIED: Las reglas no permiten lectura

## 💡 Tip de depuración:

En Firebase Console, el documento debería verse así:
```
accounts/
  └── [ID generado]
      ├── name: "Mi Banco"
      ├── bankType: "bbva"
      ├── balance: 1000
      ├── annualInterestRate: 0
      ├── createdAt: [timestamp]
      └── updatedAt: [timestamp]
```