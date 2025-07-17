# Depuración - Cuentas no se muestran

## Pasos para verificar:

1. **Reinicia la aplicación completamente**
   - Cierra la app (desliza hacia arriba)
   - Vuelve a abrirla
   
2. **En la pantalla de "Gestionar Cuentas"**
   - Toca el botón de actualizar (↻) en la parte superior
   - Esto forzará una recarga de los datos
   
3. **Si aún no aparecen las cuentas**:
   - Agrega una nueva cuenta con el botón +
   - Después de agregarla, toca el botón de actualizar (↻)

## Verificar en los logs

Al ejecutar la app, deberías ver mensajes como:
```
SyncService: Found X accounts in local database
Loaded X accounts from database
```

## Posibles causas:

1. **Primera vez ejecutando**: La base de datos se crea vacía la primera vez
2. **Firebase intentando sincronizar**: Si Firebase devuelve una lista vacía, podría estar sobrescribiendo los datos locales

## Solución temporal implementada:

- Agregué un botón de recarga manual (↻)
- La app ahora imprime logs para depuración
- Los datos se cargan automáticamente al abrir cada pantalla

## Si persiste el problema:

1. Limpia y reconstruye:
```bash
flutter clean
flutter pub get
flutter run
```

2. Borra los datos de la app en el dispositivo:
   - Android: Configuración > Apps > Finanzas Personales > Almacenamiento > Borrar datos
   - Luego vuelve a abrir la app