import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notificacion_services.dart';
import '../models/notificacion_model.dart';
import '../util/colores.dart';

class NotificacionesScreen extends StatefulWidget {
  final String idUsuario;

  const NotificacionesScreen({required this.idUsuario, super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final _service = NotificacionService();
  String _idResuelto = '';

  @override
  void initState() {
    super.initState();
    _resolverIdUsuario();
  }

  /// Si el idUsuario del parámetro está vacío, lo lee desde SharedPreferences
  Future<void> _resolverIdUsuario() async {
    if (widget.idUsuario.isNotEmpty) {
      setState(() => _idResuelto = widget.idUsuario);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id_usuario') ?? '';
    if (mounted) setState(() => _idResuelto = id);
  }

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'confirmada':   return Icons.check_circle_outline_rounded;
      case 'cancelada':    return Icons.cancel_outlined;
      case 'pendiente':    return Icons.hourglass_empty_rounded;
      case 'disponible':   return Icons.inventory_2_outlined;
      case 'devuelto':     return Icons.assignment_return_outlined;
      case 'dano':         return Icons.warning_amber_rounded;
      case 'bienvenida':   return Icons.celebration_outlined;
      case 'perfil':       return Icons.account_circle_outlined;
      case 'seguridad':    return Icons.lock_outline_rounded;
      default:             return Icons.notifications_outlined;
    }
  }

  Color _color(String tipo) {
    switch (tipo) {
      case 'confirmada':   return Colores.success;
      case 'cancelada':    return Colores.danger;
      case 'pendiente':    return Colores.warning;
      case 'disponible':   return Colores.info;
      case 'devuelto':     return Colores.primaryDark;
      case 'dano':         return Colores.danger;
      case 'bienvenida':   return Colores.primary;
      case 'perfil':       return Colores.primary;
      case 'seguridad':    return Colores.warning;
      default:             return Colores.textSecondary;
    }
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

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
              // ── Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alertas',
                            style: TextStyle(
                              color: Colores.text,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tus notificaciones en tiempo real',
                            style: TextStyle(
                              color: Colores.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_idResuelto.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _service.marcarTodasLeidas(_idResuelto),
                        icon: const Icon(Icons.done_all_rounded,
                            size: 16, color: Colores.primary),
                        label: const Text(
                          'Leídas',
                          style: TextStyle(
                              color: Colores.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Contenido ─────────────────────────────────────────
              Expanded(
                child: _idResuelto.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Colores.primary),
                      )
                    : StreamBuilder<List<Notificacion>>(
                        stream: _service.getNotificaciones(_idResuelto),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colores.primary),
                            );
                          }

                          if (snap.hasError) {
                            return _estadoVacio(
                              icon: Icons.wifi_off_rounded,
                              titulo: 'Sin conexión',
                              subtitulo: 'No se pudieron cargar las alertas',
                            );
                          }

                          final lista = snap.data ?? [];

                          if (lista.isEmpty) {
                            return _estadoVacio(
                              icon: Icons.notifications_off_outlined,
                              titulo: 'Sin alertas',
                              subtitulo:
                                  'Aquí verás las notificaciones de tus reservas',
                            );
                          }

                          // Separar leídas y no leídas
                          final noLeidas =
                              lista.where((n) => !n.leida).toList();
                          final leidas =
                              lista.where((n) => n.leida).toList();

                          return ListView(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 30),
                            children: [
                              if (noLeidas.isNotEmpty) ...[
                                _seccionHeader(
                                    '${noLeidas.length} sin leer',
                                    Colores.primary),
                                const SizedBox(height: 8),
                                ...noLeidas.map((n) => _buildItem(n)),
                                const SizedBox(height: 16),
                              ],
                              if (leidas.isNotEmpty) ...[
                                _seccionHeader('Anteriores', Colores.textMuted),
                                const SizedBox(height: 8),
                                ...leidas.map((n) => _buildItem(n)),
                              ],
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionHeader(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildItem(Notificacion n) {
    final color = _color(n.tipo);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(n.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
            color: Colores.danger,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 18),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.white, size: 22),
        ),
        onDismissed: (_) => _service.eliminarNotificacion(n.id),
        child: GestureDetector(
          onTap: () {
            if (!n.leida) _service.marcarLeida(n.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: n.leida
                  ? Colores.surfaceAlt
                  : Colores.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: n.leida
                    ? Colores.border
                    : Colores.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono del tipo
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icono(n.tipo), color: color, size: 20),
                ),
                const SizedBox(width: 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.titulo,
                              style: TextStyle(
                                color: Colores.text,
                                fontSize: 14,
                                fontWeight: n.leida
                                    ? FontWeight.w500
                                    : FontWeight.w800,
                              ),
                            ),
                          ),
                          // Punto violeta si no leída
                          if (!n.leida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colores.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        n.mensaje,
                        style: const TextStyle(
                          color: Colores.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatFecha(n.fecha),
                        style: const TextStyle(
                          color: Colores.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoVacio({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colores.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(color: Colores.border),
            ),
            child: Icon(icon, color: Colores.textMuted, size: 44),
          ),
          const SizedBox(height: 16),
          Text(titulo,
              style: const TextStyle(
                  color: Colores.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitulo,
              style: const TextStyle(
                  color: Colores.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
