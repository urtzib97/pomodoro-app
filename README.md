# Pomodoro App - Flutter

Aplicación Pomodoro minimalista construida con Flutter, GetX y SQLite.

## 🎯 Características

### Funcionales
- **Temporizador configurable** con duraciones predeterminadas:
  - 25 minutos de trabajo
  - 5 minutos de pausa corta
  - 15-30 minutos de pausa larga
- **Gestión de tareas**: agregar, marcar como completadas y asociar a pomodoros
- **Notificaciones** sonoras y visuales al finalizar ciclos
- **Estadísticas**: pomodoros completados por día y semana
- **Modo automático**: inicio automático de pausas y pomodoros

### No Funcionales
- Interfaz minimalista sin distracciones
- Persistencia local con SQLite (sin backend)
- Soporte para zona horaria WET de Canarias
- Temas claro/oscuro/automático
- Bajo consumo de recursos

## 🏗️ Arquitectura

```
lib/
├── main.dart                 # Punto de entrada
├── controllers/              # Lógica de negocio con GetX
│   ├── timer_controller.dart
│   ├── task_controller.dart
│   ├── stats_controller.dart
│   └── settings_controller.dart
├── views/                    # Pantallas de la app
│   ├── home_view.dart
│   ├── tasks_view.dart
│   ├── stats_view.dart
│   └── settings_view.dart
├── widgets/                  # Componentes reutilizables
│   ├── circular_timer.dart
│   ├── timer_controls.dart
│   ├── task_selector.dart
│   ├── task_item.dart
│   └── add_task_dialog.dart
├── models/                   # Modelos de datos
│   ├── task.dart
│   └── pomodoro_session.dart
├── services/                 # Servicios
│   ├── database_service.dart
│   └── notification_service.dart
├── database/                 # Configuración de BD
└── utils/                    # Utilidades
    └── theme.dart
```

## 📱 Pantallas

### 1. Home (Timer)
- Temporizador circular grande con tiempo restante
- Indicador de progreso visual
- Contador de pomodoros completados
- Selector de tarea actual
- Botones de control (play/pausa/reiniciar)

### 2. Tareas
- Lista de tareas pendientes y completadas
- Checkbox para marcar como completadas
- Estimación de pomodoros por tarea
- Progreso visual de cada tarea
- Deslizar para eliminar
- FAB para agregar nuevas tareas

### 3. Estadísticas
- Filtro por día/semana
- Pomodoros completados
- Tiempo total trabajado
- Tasa de completación
- Gráfico de actividad semanal
- Historial de sesiones

### 4. Configuración
- Tema (claro/oscuro/automático)
- Duraciones personalizables
- Configuración de sonidos
- Opciones de auto-inicio
- Modo pantalla completa en pausas
- Restaurar valores predeterminados

## 🎨 Diseño

### Paleta de Colores

#### Modo Claro
- Fondo: `#FAFAFA`
- Superficie: `#FFFFFF`
- Texto principal: `#212121`
- Texto secundario: `#757575`

#### Modo Oscuro
- Fondo: `#121212`
- Superficie: `#1E1E1E`
- Texto principal: `#E0E0E0`
- Texto secundario: `#BDBDBD`

#### Acentos
- Trabajo activo: `#4CAF50` (claro) / `#66BB6A` (oscuro)
- Pausa corta: `#2196F3` (claro) / `#42A5F5` (oscuro)
- Pausa larga: `#FF9800` (claro) / `#FFB74D` (oscuro)
- Completado: `#388E3C`
- Error: `#F44336`

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (para emuladores)

### Pasos

1. Clonar el repositorio:
```bash
git clone <repository-url>
cd pomodoro_app
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Ejecutar la aplicación:
```bash
flutter run
```

## 📦 Dependencias Principales

- **get**: ^4.6.6 - State management
- **sqflite**: ^2.3.0 - Base de datos local
- **flutter_local_notifications**: ^16.3.0 - Notificaciones
- **google_fonts**: ^6.1.0 - Tipografías
- **audioplayers**: ^5.2.1 - Reproducción de audio
- **intl**: ^0.18.1 - Internacionalización
- **shared_preferences**: ^2.2.2 - Preferencias locales

## 🔄 Flujo de Funcionamiento

1. **Inicio**: El usuario selecciona o agrega una tarea
2. **Trabajo**: Inicia temporizador de 25 minutos
3. **Notificación**: Al finalizar, notifica pausa de 5 minutos
4. **Ciclo**: Repite 4 veces (trabajo + pausa corta)
5. **Descanso largo**: Después de 4 pomodoros, pausa de 20-30 minutos
6. **Registro**: Todas las sesiones se guardan automáticamente
7. **Estadísticas**: Disponibles para revisión posterior

## 🎯 Características Especiales

- **Auto-inicio**: Opción para iniciar automáticamente el siguiente ciclo
- **Persistencia**: Todos los datos se guardan localmente
- **Sin conexión**: Funciona completamente offline
- **Notificaciones**: Alertas visuales y sonoras personalizables
- **Zona horaria**: Configurado para WET (Canarias)
- **Responsive**: Diseño adaptable a diferentes tamaños de pantalla

## 🧪 Testing

```bash
flutter test
```

## 📱 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👨‍💻 Autor

Desarrollado con ❤️ usando Flutter

## 🙏 Agradecimientos

- Técnica Pomodoro por Francesco Cirillo
- Flutter team por el increíble framework
- Comunidad de código abierto
