# 🚀 Inicio Rápido - Pomodoro App

## ⚡ Setup en 5 Minutos

### 1. Prerrequisitos
Asegúrate de tener instalado:
- ✅ Flutter SDK (>=3.0.0)
- ✅ Dart SDK
- ✅ Android Studio / Xcode (opcional para emuladores)
- ✅ VS Code o Android Studio como IDE

### 2. Instalación
```bash
# Navegar al directorio del proyecto
cd pomodoro_app

# Instalar dependencias
flutter pub get

# Verificar que todo está bien
flutter doctor
```

### 3. Ejecutar la App
```bash
# En dispositivo conectado o emulador
flutter run

# O especificar dispositivo
flutter devices  # Ver dispositivos disponibles
flutter run -d <device_id>
```

### 4. ¡Listo! 🎉
La app debería abrirse en tu dispositivo/emulador.

## 📱 Primera Configuración en la App

1. **Abre la app** - Verás el temporizador configurado en 25:00
2. **Opcional: Ajusta configuración** - Toca el ícono ⚙️ para personalizar duraciones
3. **Crea una tarea** - Ve a Tareas (📋) y presiona el botón +
4. **Inicia tu primer Pomodoro** - Selecciona la tarea y presiona ▶️

## 🎯 Flujo Básico

```
1. Crear Tarea → 2. Seleccionar Tarea → 3. Iniciar Timer (25 min)
                                              ↓
                                      4. Finaliza → Notificación
                                              ↓
                                      5. Pausa (5 min)
                                              ↓
                                      6. Repetir 4 veces
                                              ↓
                                      7. Pausa Larga (20 min)
```

## 🔧 Problemas Comunes

### "Command not found: flutter"
```bash
# Agregar Flutter al PATH
export PATH="$PATH:/ruta/a/flutter/bin"

# O instalar Flutter
# macOS/Linux:
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Windows: Descargar desde flutter.dev
```

### "No devices found"
```bash
# Android: Iniciar emulador
flutter emulators --launch <emulator_id>

# iOS: Abrir Simulator
open -a Simulator

# Dispositivo físico:
# - Android: Habilitar USB debugging
# - iOS: Confiar en la computadora
```

### "Gradle build failed"
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

## 📚 Documentación Completa

- 📖 **README.md** - Visión general del proyecto
- 👤 **GUIA_USUARIO.md** - Manual de usuario detallado
- 🔧 **DOCUMENTACION_TECNICA.md** - Arquitectura y detalles técnicos
- 💻 **COMANDOS.md** - Comandos útiles y troubleshooting

## 🎨 Personalización Rápida

### Cambiar duraciones predeterminadas
Edita `lib/controllers/settings_controller.dart`:
```dart
final workDuration = 25.obs;          // Cambiar a tu preferencia
final shortBreakDuration = 5.obs;     // Cambiar a tu preferencia
final longBreakDuration = 20.obs;     // Cambiar a tu preferencia
```

### Cambiar tema predeterminado
Edita `lib/controllers/settings_controller.dart`:
```dart
final themeMode = ThemeMode.dark.obs;  // light, dark, o system
```

### Cambiar colores
Edita `lib/utils/theme.dart` y modifica las constantes de color.

## 🏗️ Estructura del Proyecto

```
pomodoro_app/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── controllers/           # Lógica de negocio
│   ├── views/                # Pantallas
│   ├── widgets/              # Componentes UI
│   ├── models/               # Modelos de datos
│   ├── services/             # Servicios (DB, notificaciones)
│   └── utils/                # Utilidades (tema)
├── assets/                    # Recursos (sonidos, iconos)
├── pubspec.yaml              # Dependencias
└── README.md                 # Documentación principal
```

## 🧪 Testing

```bash
# Ejecutar tests (cuando los implementes)
flutter test

# Test específico
flutter test test/controllers/timer_controller_test.dart
```

## 📦 Build para Producción

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 💡 Tips Rápidos

- 🔄 **Hot Reload**: Presiona `r` en la terminal mientras corre la app
- 🔥 **Hot Restart**: Presiona `R` para reiniciar completamente
- 🐛 **Debug**: Usa breakpoints en VS Code/Android Studio
- 📊 **DevTools**: `flutter pub global run devtools` para herramientas avanzadas

## 🆘 Soporte

Si encuentras problemas:
1. Revisa **COMANDOS.md** para troubleshooting
2. Ejecuta `flutter doctor -v` para diagnosticar
3. Verifica que todas las dependencias estén instaladas con `flutter pub get`
4. Limpia el proyecto con `flutter clean` y vuelve a intentar

## ✅ Checklist de Verificación

Antes de comenzar a desarrollar, verifica:
- [ ] Flutter está instalado (`flutter --version`)
- [ ] Doctor no muestra errores críticos (`flutter doctor`)
- [ ] Puedes ver dispositivos conectados (`flutter devices`)
- [ ] Las dependencias se instalaron (`flutter pub get` sin errores)
- [ ] La app ejecuta correctamente (`flutter run` funciona)

## 🎓 Siguientes Pasos

1. **Explora la app** - Familiarízate con todas las pantallas
2. **Lee la documentación** - Revisa README.md y GUIA_USUARIO.md
3. **Personaliza** - Ajusta colores, duraciones, textos
4. **Agrega funcionalidades** - Consulta DOCUMENTACION_TECNICA.md
5. **Comparte** - Build y distribuye tu app

---

¡Feliz desarrollo! 🚀 Si tienes dudas, consulta la documentación completa en los archivos MD.
