SANE — Frontend (Flutter)
Guía de proyecto para asistentes de IA (Claude Code y GitHub Copilot).
Lee este archivo antes de generar o modificar código. Respeta estas
convenciones SIEMPRE; no inventes un estilo propio.

1. Qué es SANE
SANE (Smart Alimentary Navigator for Entrepreneurs) es una app que ayuda a
empresarios del sector alimentario en Colombia a saber qué permisos sanitarios
necesitan (RSA / PSA / NSA ante INVIMA o Secretarías de Salud), según la
Resolución 2674/2013. Esta es la app móvil en Flutter (también corre en web).
El flujo principal del usuario:
Splash → Onboarding → Login/Registro → Mis Negocios → (por negocio)
Diagnóstico sanitario · Asistente IA (chat) · Progreso de tramitación (rutas).

2. Stack y dependencias

Dart SDK ^3.11.5 — Material 3, solo tema oscuro. Package: sane_frontend.
dio ^5.7.0 — cliente HTTP hacia el backend.
flutter_riverpod ^2.6.1 — manejo de estado (providers).
go_router ^14.6.2 — navegación.
flutter_secure_storage ^9.2.2 + shared_preferences ^2.3.3 — token JWT y prefs.
(En web flutter_secure_storage necesita fallback → para eso está shared_preferences.)
web_socket_channel ^2.4.0 — streaming del Chat / Asistente IA (pendiente en back; usar mock).
cupertino_icons ^1.0.8, flutter_lints ^6.0.0 (dev).


Antes de añadir una dependencia nueva, pregúntame/confírmalo. No metas
paquetes que dupliquen lo que ya tenemos.


3. Estructura de carpetas
lib/
  main.dart
  core/
    api/        api_client.dart, api_exception.dart
    storage/    token_storage.dart
    theme/      app_colors.dart, app_theme.dart, app_spacing.dart, app_shadows.dart
    config/  constants/   (vacías por ahora)
  models/       *_model.dart (business, chat, diagnostic, progress, route, user)
  providers/    *_provider.dart (Riverpod: auth, business, diagnostic, chat, route, progress)
  router/       app_router.dart (go_router)
  screens/      una carpeta por feature: auth/, business/, chat/, diagnostic/,
                home/, profile/, progress/, routes/  + splash_screen, shell_screen
  widgets/      componentes reutilizables (ver inventario abajo)
Una pantalla nueva = nueva carpeta en screens/<feature>/.
Componentes reutilizables van en widgets/, NO copiados dentro de cada pantalla.
NOTA: las carpetas data/, domain/, presentation/ y routing/ están vacías
(sobras del andamiaje). No las uses; si vas a crear algo, ubícalo según el
esquema real de arriba.
Widgets reutilizables ya existentes (REUTILIZAR antes de crear nuevos)

premium_card.dart — card base con estilo (úsala para cualquier tarjeta).
status_chip.dart — chip de estado/riesgo/etiqueta.
animated_button.dart — botón con animación (acción primaria).
animated_bottom_nav.dart — barra inferior (Inicio/Rutas/Perfil).
animated_orbs_background.dart — fondo animado de orbes neón (reutilizable
en cualquier pantalla que quiera el fondo inmersivo).
sane_logo.dart — logo completo (escudo + "SANE"). Para headers usar el
asset solo-escudo assets/images/sane_logo_mark.png.
empty_state.dart, error_view.dart, shimmer_loader.dart — estados vacío,
error y carga (úsalos siempre en vez de improvisar).
gradient_text.dart, animated_badge.dart, responsive_layout.dart.


4. Reglas de diseño visual (CRÍTICO)
El objetivo es una UI pulida, no plana. Reglas firmes:

Nunca uses colores hardcodeados (Color(0xFF...) ni Colors.blue).
Usa siempre AppColors.* y los estilos de AppTheme.
Tema oscuro neón únicamente (fondo casi negro + acentos cian/lima brillantes).
Campos disponibles en AppColors (usar estos nombres exactos):

Fondos: background, surface, surfaceAlt, surfaceHigh.
Primario (cian): primary, primaryLight, primaryDark, onPrimary.
Acentos (lima/teal): secondary, secondaryLight, tertiary.
Estados: success/successLight, warning/warningLight,
error/errorLight, info.
Texto: textPrimary, textSecondary, textMuted, textDisabled.
Bordes/divisores: border, borderLight, divider.
Glassmorphism: glassSurface, glassLight (overlays blancos translúcidos).
Categorías/riesgo: catHome, catMobile, catLocal, catPlant,
catFoodService, catRiskHigh, catRiskMedium, catRiskLow.


Tipografía: usa Theme.of(context).textTheme.*, no tamaños sueltos.
Cards: radio 16px. Botones: alto 52px, radio 12px (ya definidos en AppTheme).
Spacing y sombras: usa los helpers AppSpacing y AppShadows
(lib/core/theme/), no números mágicos sueltos. Escala en múltiplos de 8.
Mobile-first: usa responsive_layout.dart para mantener el ancho móvil en web.
Jerarquía visual: título > subtítulo > cuerpo; usa peso y color, no solo tamaño.
Estados siempre visibles: loading, vacío y error. Ninguna pantalla debe
quedarse en blanco mientras carga o si falla.


5. Integración con el backend
Patrón de repositorios: cada feature tiene un repositorio con interfaz, y una
implementación real (dio) o mock. Esto permite construir UI aunque el back no
esté listo, y cambiar a real con una sola línea del provider.
Estado actual del backend:

Funciona (usar repos reales): Auth (login/registro/JWT), Negocios
(crear/listar/detalle), Diagnóstico (responder cuestionario + resultado del
motor de reglas).
Pendiente (usar repos MOCK por ahora): Asistente IA / Chat y Rutas /
Progreso de tramitación. El equipo de back los está arreglando. NO conectar
estos a real todavía; dejar el mock y un TODO claro.

baseUrl y el token van centralizados en el cliente dio; no hardcodear URLs
en las pantallas. En desarrollo local: baseUrl = "http://localhost:8001"
(el back corre en el puerto 8001).

6. Convenciones de código

Widgets const siempre que sea posible.
Comentarios y textos de UI en español (es el idioma del equipo y la app).
Nombres de archivos en snake_case.dart, clases en PascalCase.
Lógica de negocio/estado fuera de los build; usa providers de Riverpod.
No dejes print ni código muerto. Formatea con dart format al guardar.


7. Cómo trabajar conmigo (el asistente)

Trabaja una pantalla / un componente a la vez. No reescribas medio
proyecto en un solo paso.
Antes de un cambio multi-archivo, explica brevemente el plan.
Si algo no está en este archivo y es una decisión de arquitectura,
pregúntame antes de inventar.
Reutiliza componentes existentes antes de crear nuevos.