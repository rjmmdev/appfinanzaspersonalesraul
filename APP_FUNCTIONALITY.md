# Funcionalidad de la Aplicación Finanzas Personales

## Cómo funciona la persistencia de datos

La aplicación utiliza un **sistema dual de persistencia**:

### 1. Base de Datos Local (SQLite)
- **Siempre disponible**: Funciona sin conexión a internet
- **Respuesta inmediata**: Los datos se guardan y leen instantáneamente
- **Persistencia garantizada**: Todos los cambios se guardan localmente primero

### 2. Sincronización con Firebase (Opcional)
- **Respaldo en la nube**: Si Firebase está configurado, los datos se sincronizan automáticamente
- **No bloquea la app**: Si Firebase no está disponible, la app sigue funcionando normalmente
- **Silencioso**: Los errores de Firebase no interrumpen la experiencia del usuario

## Flujo de datos

1. **Al agregar una cuenta/transacción**:
   - Se guarda primero en SQLite (local)
   - Se intenta sincronizar con Firebase en segundo plano
   - El usuario ve el cambio inmediatamente

2. **Al consultar datos**:
   - Se leen primero de SQLite
   - Si Firebase está disponible, se obtienen datos actualizados
   - Si no, se usan los datos locales

3. **Cálculo de intereses**:
   - Se ejecuta al iniciar la app
   - Calcula intereses diarios para cuentas configuradas:
     - Mercado Pago: 14% anual
     - DIDI: 15% anual
   - Actualiza balances automáticamente

## Estado actual

✅ **Funciona completamente offline**
- No necesitas configurar Firebase para usar la app
- Todos los datos se guardan localmente
- Las transacciones actualizan los balances de las cuentas
- Los intereses se calculan diariamente

⚠️ **Firebase es opcional**
- Si ves errores de "PERMISSION_DENIED", son normales
- La app los ignora y sigue funcionando con datos locales
- Puedes habilitar Firebase siguiendo las instrucciones en FIRESTORE_SETUP.md

## Características implementadas

1. **Gestión de cuentas bancarias**
   - BBVA, Mercado Pago, Nu, DIDI
   - Balances actualizados en tiempo real
   - Tasas de interés configurables

2. **Registro de transacciones**
   - Ingresos y gastos
   - Cálculo automático de IVA
   - Soporte para gastos deducibles (RESICO)
   - Categorización de gastos

3. **Persistencia robusta**
   - Base de datos local SQLite
   - Sincronización opcional con Firebase
   - Funcionamiento garantizado sin internet

4. **Cálculos automáticos**
   - Intereses diarios para cuentas de inversión
   - Actualización de balances al registrar transacciones
   - Totales y estadísticas en tiempo real
5. **Actualización diaria en Firebase**
   - Función programada `applyDailyInterest` se ejecuta a las 00:10 AM
   - Calcula y aplica intereses en las cuentas con tasa anual
   - Guarda registros en `daily_interest_records` y actualiza balances