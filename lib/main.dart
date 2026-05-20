import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SaneApp());
}

/// Raiz de la app. Por ahora muestra una pantalla "showcase" del design system
/// para verificar que el tema oscuro se aplica bien. En el sub-paso B la
/// reemplazaremos por el router real (go_router) con Splash/Login/etc.
class SaneApp extends StatelessWidget {
  const SaneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SANE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const ThemeShowcaseScreen(),
    );
  }
}

/// Pantalla temporal para ver los colores y componentes del design system.
class ThemeShowcaseScreen extends StatelessWidget {
  const ThemeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SANE — Design System')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('SANE', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primaryHover, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Smart Alimentary Navigator for Entrepreneurs',
            style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          // Card de ejemplo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tu progreso',
                    style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('33% completado · 1 de 3 tareas',
                    style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(value: 0.33, minHeight: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Inputs de ejemplo
          const TextField(
            decoration: InputDecoration(
              labelText: 'Correo electronico',
              hintText: 'tu@email.com',
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Contrasena'),
          ),
          const SizedBox(height: 20),

          // Botones
          ElevatedButton(onPressed: () {}, child: const Text('Iniciar diagnostico')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () {}, child: const Text('Anterior')),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Olvide mi contrasena')),
          const SizedBox(height: 24),

          // Chips de estado
          Wrap(
            spacing: 8,
            children: [
              _statusChip('Completado', AppColors.success),
              _statusChip('En proceso', AppColors.info),
              _statusChip('Pendiente', AppColors.textMuted),
              _statusChip('Error', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
