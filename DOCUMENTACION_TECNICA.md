# Documentación Técnica - Pomodoro App

## 🏛️ Arquitectura

### Patrón de Diseño
La aplicación utiliza el patrón **MVC (Model-View-Controller)** implementado con GetX:

- **Models**: Representación de datos (Task, PomodoroSession)
- **Views**: Interfaces de usuario (HomeView, TasksView, etc.)
- **Controllers**: Lógica de negocio y state management

### Estado de la Aplicación (State Management)
Utilizamos **GetX** para:
- Gestión reactiva del estado con `Obs` y `Obx`
- Inyección de dependencias con `Get.put` y `Get.find`
- Navegación declarativa con `Get.to` y `Get.back`
- Almacenamiento de preferencias

## 📊 Base de Datos

### Schema SQLite

#### Tabla: tasks
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  estimatedPomodoros INTEGER NOT NULL,
  completedPomodoros INTEGER DEFAULT 0,
  isCompleted INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,
  completedAt TEXT
);
```

#### Tabla: pomodoro_sessions
```sql
CREATE TABLE pomodoro_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  taskId INTEGER,
  startTime TEXT NOT NULL,
  endTime TEXT,
  duration INTEGER NOT NULL,
  completed INTEGER DEFAULT 0,
  type TEXT NOT NULL,
  FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE SET NULL
);
```

### Operaciones CRUD

#### Tareas
- `insertTask()`: Crea una nueva tarea
- `getAllTasks()`: Obtiene todas las tareas ordenadas por fecha
- `getActiveTasks()`: Filtra tareas no completadas
- `updateTask()`: Actualiza una tarea existente
- `deleteTask()`: Elimina una tarea por ID

#### Sesiones
- `insertSession()`: Registra una nueva sesión
- `getAllSessions()`: Obtiene todas las sesiones
- `getSessionsByDateRange()`: Filtra por rango de fechas
- `getCompletedPomodorosToday()`: Cuenta pomodoros del día
- `getCompletedPomodorosThisWeek()`: Cuenta pomodoros de la semana

## 🎮 Controllers

### TimerController
**Responsabilidad**: Gestión del temporizador Pomodoro

**Estados**:
```dart
enum TimerState { idle, running, paused, break_time }
enum BreakType { none, short_break, long_break }
```

**Propiedades observables**:
- `timerState`: Estado actual del temporizador
- `remainingSeconds`: Segundos restantes
- `totalSeconds`: Duración total del ciclo
- `completedPomodoros`: Contador de pomodoros
- `currentBreakType`: Tipo de pausa actual

**Métodos principales**:
- `startTimer()`: Inicia o reanuda el temporizador
- `pauseTimer()`: Pausa el temporizador
- `resetTimer()`: Reinicia el temporizador al estado inicial
- `skipToBreak()`: Salta directamente a la pausa
- `skipBreak()`: Salta la pausa actual

**Flujo de trabajo**:
```
idle → running → (25 min) → break_time → running → ...
                      ↓
              completedPomodoros++
                      ↓
           Registra sesión en BD
```

### TaskController
**Responsabilidad**: Gestión de tareas

**Propiedades observables**:
- `tasks`: Lista de todas las tareas
- `selectedTask`: Tarea actualmente seleccionada
- `completedTasksCount`: Contador de tareas completadas hoy

**Métodos principales**:
- `addTask()`: Agrega una nueva tarea
- `toggleTaskCompletion()`: Marca/desmarca como completada
- `deleteTask()`: Elimina una tarea
- `incrementTaskPomodoro()`: Incrementa pomodoros completados
- `selectTask()`: Selecciona la tarea activa

### StatsController
**Responsabilidad**: Cálculo y presentación de estadísticas

**Propiedades observables**:
- `todayPomodoros`: Pomodoros completados hoy
- `weekPomodoros`: Pomodoros completados esta semana
- `todaySessions`: Sesiones del día
- `weekSessions`: Sesiones de la semana
- `selectedPeriod`: Periodo de visualización ('today' o 'week')

**Métodos calculados**:
- `totalMinutes`: Suma de minutos trabajados
- `completionRate`: Porcentaje de sesiones completadas
- `dailyBreakdown`: Distribución diaria para gráfico semanal

### SettingsController
**Responsabilidad**: Configuración de la aplicación

**Configuraciones guardadas en SharedPreferences**:
- `themeMode`: Tema (light/dark/system)
- `workDuration`: Duración del trabajo (minutos)
- `shortBreakDuration`: Duración de pausa corta (minutos)
- `longBreakDuration`: Duración de pausa larga (minutos)
- `pomodorosBeforeLongBreak`: Ciclos antes de pausa larga
- `soundEnabled`: Estado de sonidos
- `fullscreenBreaks`: Modo pantalla completa
- `autoStartBreaks`: Auto-inicio de pausas
- `autoStartPomodoros`: Auto-inicio de pomodoros

## 🔔 Notificaciones

### NotificationService
**Configuración**:
```dart
AndroidNotificationDetails(
  'pomodoro_channel',
  'Pomodoro Notifications',
  importance: Importance.high,
  priority: Priority.high,
)
```

**Eventos que generan notificaciones**:
1. Finalización de sesión de trabajo
2. Finalización de pausa corta
3. Finalización de pausa larga

**Personalización**:
- Título y cuerpo dinámicos según el evento
- Sonido opcional según configuración
- Icono de la aplicación

## 🎨 Theming

### Sistema de Temas
Implementado con `ThemeData` de Material 3:

**ColorScheme**:
- `primary`: Color principal (trabajo)
- `secondary`: Color secundario (pausa corta)
- `tertiary`: Color terciario (pausa larga)
- `surface`: Color de superficies (cards)
- `background`: Color de fondo

**Tipografía**:
- Familia: Google Fonts - Inter
- Pesos: 300 (Light), 400 (Regular), 600 (SemiBold), 700 (Bold)
- Características: Figuras tabulares para el temporizador

## 🔄 Ciclo de Vida

### Inicialización de la App
```dart
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar base de datos
  await Get.putAsync(() => DatabaseService().init());
  
  // 2. Inicializar notificaciones
  await NotificationService.initialize();
  
  // 3. Inicializar controllers
  Get.put(SettingsController());
  Get.put(TaskController());
  Get.put(StatsController());
  Get.put(TimerController());
  
  // 4. Configurar orientación
  await SystemChrome.setPreferredOrientations([...]);
  
  runApp(PomodoroApp());
}
```

### Persistencia de Datos
- **SQLite**: Tareas y sesiones
- **SharedPreferences**: Configuraciones
- **GetX Reactive**: Estado en memoria

## 🧪 Testing

### Áreas de Testing Recomendadas

#### Unit Tests
- Models: Serialización/deserialización
- Controllers: Lógica de negocio
- Services: Operaciones de BD

#### Widget Tests
- Views: Renderizado correcto
- Widgets: Interacciones de usuario
- Navegación: Rutas correctas

#### Integration Tests
- Flujo completo de pomodoro
- CRUD de tareas
- Persistencia de datos

### Ejemplo de Test
```dart
test('Timer should decrement seconds', () {
  final controller = TimerController();
  controller.startTimer();
  
  expect(controller.remainingSeconds.value, 
         lessThan(controller.totalSeconds.value));
});
```

## 📱 Optimizaciones

### Rendimiento
- **Reactive Updates**: Solo se reconstruyen widgets afectados
- **Lazy Loading**: Controladores inicializados bajo demanda
- **Database Indexing**: Índices en campos de búsqueda frecuente
- **Efficient Queries**: Uso de WHERE clauses apropiadas

### Memoria
- **Dispose**: Limpieza de controllers en onClose()
- **Timer Management**: Cancelación de timers al destruir
- **Stream Closing**: Cierre de subscripciones

## 🌍 Internacionalización

### Zona Horaria
Configurado para **WET (Western European Time)** - Canarias:
- UTC+0 en invierno
- UTC+1 en verano (horario de verano)

### Formato de Fechas
Uso de `intl` package:
```dart
final DateFormat('HH:mm'); // Formato 24 horas
final DateFormat('dd/MM/yyyy'); // Formato fecha
```

## 🔒 Seguridad

### Datos Locales
- SQLite: Encriptación opcional (no implementada por defecto)
- SharedPreferences: Datos en texto plano (configuraciones no sensibles)

### Permisos
- **Android**: Notificaciones
- **iOS**: Notificaciones

## 🚀 Despliegue

### Build Configurations

#### Debug
```bash
flutter run --debug
```

#### Release
```bash
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### Configuración de Versiones
- Incrementar en `pubspec.yaml`
- Formato: `version: 1.0.0+1` (version+build)

## 📊 Monitoreo

### Logs
- Eventos importantes logueados en debug
- Errores capturados y mostrados en consola
- No hay logging en producción por defecto

### Analytics (No implementado)
Posibles integraciones futuras:
- Firebase Analytics
- Sentry para error tracking
- Mixpanel para eventos de usuario

## 🔮 Mejoras Futuras

### Funcionalidades
1. Sincronización en la nube
2. Modo colaborativo (equipos)
3. Integración con calendarios
4. Exportación de estadísticas (CSV/PDF)
5. Widgets de pantalla de inicio
6. Wearable support (smartwatch)

### Técnicas
1. Tests automatizados completos
2. CI/CD pipeline
3. Migración a arquitectura modular
4. Implementación de Clean Architecture
5. Offline-first con sincronización
6. Encriptación de datos sensibles

---

Para más información, consulta el README.md y GUIA_USUARIO.md
