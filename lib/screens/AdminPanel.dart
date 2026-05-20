import 'package:flutter/material.dart';
import '../util/colores.dart';
import 'AdminUsuarios.dart';
import 'AdminCategorias.dart';

class PantallaAdminPanel extends StatelessWidget {
  const PantallaAdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromRGBO(18, 22, 30, 1), Colores.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildAdminCard(
                      context: context,
                      title: 'Gestión de Usuarios',
                      subtitle: 'Controlar roles, ver datos de contacto y dar de baja usuarios.',
                      icon: Icons.people_outline_rounded,
                      dest: const PantallaAdminUsuarios(),
                    ),
                    const SizedBox(height: 16),
                    _buildAdminCard(
                      context: context,
                      title: 'Gestión de Categorías',
                      subtitle: 'Agregar, modificar o eliminar categorías del catálogo de recursos.',
                      icon: Icons.category_outlined,
                      dest: const PantallaAdminCategorias(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colores.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel de Control',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Herramientas administrativas del sistema',
                  style: TextStyle(
                    color: Colores.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget dest,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => dest),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.border),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colores.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colores.border),
              ),
              child: Icon(icon, color: Colores.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colores.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colores.textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}
