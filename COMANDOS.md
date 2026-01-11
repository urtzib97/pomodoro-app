# Comandos de Desarrollo y Troubleshooting

## 🚀 Comandos Principales

### Instalación y Setup
```bash
# Instalar dependencias
flutter pub get

# Limpiar caché de build
flutter clean

# Obtener información del entorno
flutter doctor -v

# Verificar dispositivos conectados
flutter devices
```

### Ejecución
```bash
# Ejecutar en modo debug
flutter run

# Ejecutar en dispositivo específico
flutter run -d <device_id>

# Ejecutar con hot reload
flutter run --hot

# Ejecutar en modo release
flutter run --release

# Ejecutar en modo profile (para análisis de rendimiento)
flutter run --profile
```

### Build
```bash
# Android APK
flutter build apk --release
flutter build apk --split-per-abi  # APKs separados por arquitectura

# Android App Bundle (para Google Play)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Testing
```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar test específico
flutter test test/models/task_test.dart

# Ejecutar integration tests
flutter test integration_test/app_test.dart
```

### Análisis y Formato
```bash
# Analizar código
flutter analyze

# Formatear código
flutter format .

# Verificar formato sin modificar
flutter format --set-exit-if-changed .
```

### Dependencias
```bash
# Actualizar dependencias
flutter pub upgrade

# Actualizar solo dependencias mayores
flutter pub upgrade --major-versions

# Ver dependencias desactualizadas
flutter pub outdated

# Agregar nueva dependencia
flutter pub add package_name

# Remover dependencia
flutter pub remove package_name
```

## 🔧 Troubleshooting

### Problema: "Gradle build failed"
```bash
# Solución 1: Limpiar proyecto
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get

# Solución 2: Invalidar caché
flutter clean
rm -rf ~/.gradle/caches/
flutter pub get

# Solución 3: Actualizar Gradle
# Editar android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

### Problema: "Pod install failed" (iOS)
```bash
# Solución 1: Actualizar CocoaPods
cd ios
pod repo update
pod install
cd ..

# Solución 2: Limpiar pods
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# Solución 3: Reinstalar CocoaPods
sudo gem uninstall cocoapods
sudo gem install cocoapods
```

### Problema: "SQLite database is locked"
```dart
// Solución: Cerrar correctamente la base de datos
@override
void dispose() {
  _database?.close();
  super.dispose();
}

// Verificar que no hay múltiples instancias
// Usar singleton pattern para DatabaseService
```

### Problema: "Notifications not showing"
```bash
# Android - Verificar permisos en AndroidManifest.xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

# iOS - Verificar permisos en Info.plist
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

### Problema: "GetX controller not found"
```dart
// Solución 1: Asegurar inicialización
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(SettingsController());  // Inicializar antes de runApp
  runApp(MyApp());
}

// Solución 2: Usar Get.lazyPut si no se usa inmediatamente
Get.lazyPut(() => TimerController());

// Solución 3: Verificar que el controller existe
if (Get.isRegistered<TimerController>()) {
  final controller = Get.find<TimerController>();
}
```

### Problema: "SharedPreferences not saving"
```dart
// Solución: Usar await para operaciones async
Future<void> saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('key', 'value');  // await importante
}

// Verificar inicialización
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Necesario
  await SharedPreferences.getInstance();
  runApp(MyApp());
}
```

### Problema: "Timer not accurate"
```dart
// Solución: Usar Duration exacta y verificar elapsed time
Timer.periodic(Duration(seconds: 1), (timer) {
  // No asumir que cada tick es exactamente 1 segundo
  // Calcular diferencia con DateTime si necesitas precisión
});

// Alternativa más precisa:
final startTime = DateTime.now();
Timer.periodic(Duration(milliseconds: 100), (timer) {
  final elapsed = DateTime.now().difference(startTime);
  final remainingSeconds = totalSeconds - elapsed.inSeconds;
  // Actualizar UI
});
```

## 🐛 Debugging

### Herramientas de Debug
```bash
# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Debug con logs
flutter run --debug
# En el código:
debugPrint('Debug message');

# Habilitar logging de SQLite
# En database_service.dart:
await openDatabase(
  path,
  version: 1,
  onCreate: _onCreate,
  onOpen: (db) {
    debugPrint('Database opened: $path');
  },
);
```

### Breakpoints y Debug
```dart
// Agregar breakpoint en código
import 'dart:developer';

void someFunction() {
  debugger();  // Pausa ejecución aquí
  // código...
}
```

### Inspección de Widget Tree
```bash
# En DevTools, usar Widget Inspector
# O agregar en código:
debugDumpApp();  // Imprime árbol de widgets
debugDumpRenderTree();  // Imprime árbol de render
```

## 📊 Performance

### Análisis de Rendimiento
```bash
# Profile build
flutter run --profile

# Analizar con DevTools
flutter pub global run devtools

# Medir tiempo de build
flutter run --trace-startup

# Analizar tamaño del APK
flutter build apk --analyze-size
```

### Optimización de Build
```dart
// Usar const constructors
const Text('Hello');  // ✅ Mejor
Text('Hello');        // ❌ Evitar si es constante

// Evitar rebuilds innecesarios con Obx
Obx(() => Text(controller.value.toString()));  // ✅
// vs
GetBuilder<Controller>(builder: (controller) => ...);  // Más pesado
```

## 🔍 Logs y Monitoring

### Ver logs en tiempo real
```bash
# Android
flutter logs
# o
adb logcat | grep flutter

# iOS
flutter logs
# o
idevicesyslog
```

### Filtrar logs
```bash
# Solo errores
flutter logs | grep -i error

# Solo de la app
flutter logs | grep -i "pomodoro"
```

## 📱 Device Testing

### Emuladores
```bash
# Listar emuladores Android
flutter emulators

# Crear emulador Android
flutter emulators --create

# Ejecutar emulador específico
flutter emulators --launch <emulator_id>

# iOS Simulator
open -a Simulator
```

### Dispositivos físicos
```bash
# Android - Habilitar USB debugging en el dispositivo
adb devices

# iOS - Confiar en el dispositivo
idevice_id -l

# Instalar en dispositivo
flutter install -d <device_id>
```

## 🔐 Signing y Release

### Android Signing
```bash
# Generar keystore
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Configurar en android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=key
storeFile=<path-to-key.jks>
```

### iOS Signing
```bash
# Configurar en Xcode
# 1. Abrir ios/Runner.xcworkspace
# 2. Signing & Capabilities
# 3. Seleccionar Team
# 4. Automatic signing
```

## 🌐 Deployment

### Google Play Store
```bash
# Build app bundle
flutter build appbundle --release

# Archivo en: build/app/outputs/bundle/release/app-release.aab
```

### Apple App Store
```bash
# Build iOS
flutter build ios --release

# Abrir Xcode y archivar
open ios/Runner.xcworkspace
# Product > Archive
# Upload to App Store
```

### Web Hosting
```bash
# Build web
flutter build web --release

# Deploy a Firebase Hosting
firebase init hosting
firebase deploy
```

## 📚 Recursos Útiles

### Documentación
- [Flutter Docs](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [SQLite Tutorial](https://www.sqlitetutorial.net/)

### Comandos de Referencia Rápida
```bash
flutter doctor          # Verificar instalación
flutter clean          # Limpiar build
flutter pub get        # Instalar dependencias
flutter run           # Ejecutar app
flutter build apk     # Build Android
flutter build ios     # Build iOS
flutter test          # Ejecutar tests
flutter analyze       # Analizar código
```

---

💡 **Tip**: Mantén siempre actualizado Flutter con `flutter upgrade`
