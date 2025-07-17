# Configuración de Cloud Firestore

## Pasos para habilitar Firestore:

1. **Abre la consola de Firebase**
   - Ve a https://console.firebase.google.com/
   - Selecciona tu proyecto "finanzaspersonalesraul"

2. **Habilita Cloud Firestore**
   - En el menú lateral, haz clic en "Firestore Database"
   - Haz clic en "Crear base de datos"
   - Selecciona "Comenzar en modo de producción" o "Comenzar en modo de prueba"
     - Modo de prueba: Permite lectura/escritura libre por 30 días (bueno para desarrollo)
     - Modo de producción: Requiere configurar reglas de seguridad

3. **Selecciona la ubicación**
   - Elige una ubicación cercana (ej: us-central1 o southamerica-east1)
   - Haz clic en "Habilitar"

4. **Configura las reglas de seguridad (importante)**
   Si elegiste modo de producción, actualiza las reglas en "Reglas" con algo como:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Permitir lectura/escritura solo a usuarios autenticados
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Espera unos minutos**
   - La API puede tardar 2-5 minutos en activarse completamente

## Alternativa: Usar solo base de datos local

Si prefieres no usar Firebase, la app funcionará perfectamente solo con SQLite local.