import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'DetalleReserva.dart';

class PantallaMisReservas extends StatefulWidget {
  const PantallaMisReservas({super.key});

  @override
  PantallaMisReservasState createState() => PantallaMisReservasState();
}

class PantallaMisReservasState extends State<PantallaMisReservas> {
  // reserva = { ...ReservaUsuario, 'nombre_recurso', 'descripcion_recurso', 'foto_recurso' }
  List<Map<String, dynamic>> reservas = [];
  bool _cargando = true;
  String _error = '';
  String _filtro = 'todas';

  final List<Map<String, String>> filtros = [
    {'label': 'Todas',     'value': 'todas'},
    {'label': 'Activas',   'value': 'activa'},
    {'label': 'Pendiente', 'value': 'pendiente'},
    {'label': 'Canceladas','value': 'cancelada'},
  ];

  @override
  void initState() {
    super.initState();
    fetchMisReservas();
  }

  Future<void> fetchMisReservas() async {
    setState(() { _cargando = true; _error = ''; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      // 1. Obtener lista de reservas del usuario
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/reservas_usuario/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() { _cargando = false; _error = 'Error ${res.statusCode}'; });
        return;
      }

      final List<dynamic> lista = jsonDecode(res.body);

      // 2. Para cada reserva, obtener los datos del recurso
      final enriquecidas = await Future.wait(
        lista.map((raw) async {
          // El schema usa alias: recurso_id → "reserva_id" en JSON
          final ru = Map<String, dynamic>.from(raw as Map);
          final recursoId = ru['reserva_id'] ?? ru['recurso_id'];

          try {
            final recursoRes = await http.get(
              Uri.parse('${AppConfig.baseUrl}/reservas/$recursoId'),
              headers: {'Authorization': 'Bearer $token'},
            );
            if (recursoRes.statusCode == 200) {
              final r = jsonDecode(recursoRes.body) as Map<String, dynamic>;
              return <String, dynamic>{
                ...ru,
                'nombre_recurso':      r['name'] ?? r['nombre'] ?? 'Recurso',
                'descripcion_recurso': r['description'] ?? r['descripcion'] ?? '',
                'foto_recurso':        r['foto_principal'],
                'precio_por_hora':     r['precio_por_hora'],
                'calificacion':        r['calificacion_promedio'],
              };
            }
          } catch (_) {}
          return <String, dynamic>{
            ...ru,
            'nombre_recurso':      'Recurso #$recursoId',
            'descripcion_recurso': '',
            'foto_recurso':        null,
            'precio_por_hora':     null,
            'calificacion':        null,
          };
        }),
      );

      if (!mounted) return;
      setState(() {
        reservas = enriquecidas.cast<Map<String, dynamic>>();
        _cargando = false;
      });
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = 'Sin conexión al servidor'; });
    }
  }

  List<Map<String, dynamic>> get reservasFiltradas {
    if (_filtro == 'todas') return reservas;
    return reservas
        .where((r) => (r['estado'] ?? '').toString().toLowerCase() == _filtro)
        .toList();
  }

  // ── Helpers de estado ──────────────────────────────────────────────
  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
      case 'confirmada': return Colores.success;
      case 'pendiente':  return Colores.warning;
      case 'cancelada':  return Colores.danger;
      default:           return Colores.textSecondary;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
      case 'confirmada': return Icons.check_circle_rounded;
      case 'pendiente':  return Icons.hourglass_top_rounded;
      case 'cancelada':  return Icons.cancel_rounded;
      default:           return Icons.help_rounded;
    }
  }

  String _etiquetaEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':     return 'Activa';
      case 'confirmada': return 'Confirmada';
      case 'pendiente':  return 'Pendiente';
      case 'cancelada':  return 'Cancelada';
      default:           return estado;
    }
  }

  String _formatFecha(String? f) {
    if (f == null || f.isEmpty) return '—';
    // yyyy-mm-dd → dd/mm/yy
    try {
      final p = f.split('-');
      return '${p[2]}/${p[1]}/${p[0].substring(2)}';
    } catch (_) { return f; }
  }

  String _formatHora(String? h) {
    if (h == null || h.isEmpty) return '—';
    return h.substring(0, 5); // HH:mm
  }

  // Cuantas reservas activas hay
  int get _activasCount => reservas
      .where((r) => (r['estado'] ?? '').toString().toLowerCase() == 'activa' ||
                    (r['estado'] ?? '').toString().toLowerCase() == 'confirmada')
      .length;

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
              _buildHeader(),
              if (!_cargando && reservas.isNotEmpty) _buildResumenBanner(),
              const SizedBox(height: 12),
              _buildFiltros(),
              const SizedBox(height: 12),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Reservas',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _cargando
                      ? 'Cargando...'
                      : '${reservas.length} reserva${reservas.length != 1 ? 's' : ''} registradas',
                  style: const TextStyle(color: Colores.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: fetchMisReservas,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colores.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colores.border),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colores.icon, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner resumen ─────────────────────────────────────────────────
  Widget _buildResumenBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colores.primaryDark.withOpacity(0.7),
              Colores.primary.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colores.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_available_rounded, color: Colores.text, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESUMEN',
                    style: TextStyle(
                      color: Colores.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_activasCount reserva${_activasCount != 1 ? 's' : ''} activa${_activasCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _miniStat('${reservas.length}', 'Total'),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colores.text, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colores.textSecondary, fontSize: 11)),
      ],
    );
  }

  // ── Filtros ────────────────────────────────────────────────────────
  Widget _buildFiltros() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filtros[i];
          final sel = _filtro == f['value'];
          // Contar reservas por filtro
          final count = f['value'] == 'todas'
              ? reservas.length
              : reservas.where((r) => (r['estado'] ?? '').toString().toLowerCase() == f['value']).length;
          return GestureDetector(
            onTap: () => setState(() => _filtro = f['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? Colores.primaryDark : Colores.surfaceAlt,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: sel ? Colores.primary : Colores.border,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    f['label']!,
                    style: TextStyle(
                      color: sel ? Colores.text : Colores.textSecondary,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: sel
                            ? Colores.primary.withOpacity(0.35)
                            : Colores.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: sel ? Colores.text : Colores.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colores.primary));
    }
    if (_error.isNotEmpty) {
      return _buildEstadoVacio(
        icon: Icons.wifi_off_rounded,
        titulo: 'Sin conexión',
        subtitulo: _error,
        boton: 'Reintentar',
        onBoton: fetchMisReservas,
      );
    }
    final lista = reservasFiltradas;
    if (lista.isEmpty) {
      return _buildEstadoVacio(
        icon: Icons.calendar_today_outlined,
        titulo: _filtro == 'todas' ? 'Aún no tienes reservas' : 'Sin reservas con ese estado',
        subtitulo: _filtro == 'todas'
            ? 'Explora los recursos disponibles y haz tu primera reserva.'
            : 'Cambia el filtro para ver otras reservas.',
      );
    }
    return RefreshIndicator(
      color: Colores.primary,
      backgroundColor: Colores.surfaceAlt,
      onRefresh: fetchMisReservas,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildCard(lista[i]),
      ),
    );
  }

  // ── Tarjeta de reserva ─────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> r) {
    final estado = (r['estado'] ?? 'pendiente').toString().toLowerCase();
    final color  = _colorEstado(estado);
    final precio = r['precio_total'];
    final foto   = r['foto_recurso'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PantallaDetalleReserva(reserva: r)),
      ).then((v) { if (v == true) fetchMisReservas(); }),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Franja superior con color de estado ──────────────────
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen o ícono de estado
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: foto != null && foto.toString().isNotEmpty
                        ? Image.network(
                            foto,
                            width: 56, height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _iconBox(color),
                          )
                        : _iconBox(color),
                  ),
                  const SizedBox(width: 13),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['nombre_recurso'] ?? 'Sin nombre',
                          style: const TextStyle(
                            color: Colores.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        // Fecha
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: Colores.icon),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatFecha(r['fecha_inicio']?.toString())}  ·  ${_formatHora(r['hora_inicio']?.toString())} – ${_formatHora(r['hora_fin']?.toString())}',
                              style: const TextStyle(
                                color: Colores.textSecondary, fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (precio != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined,
                                  size: 12, color: Colores.primary),
                              const SizedBox(width: 4),
                              Text(
                                '\$${(precio as num).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colores.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Badge estado + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_iconoEstado(estado), color: color, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              _etiquetaEstado(estado),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colores.textMuted, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(Color color) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.domain_rounded, color: color.withOpacity(0.7), size: 26),
    );
  }

  Widget _buildEstadoVacio({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    String? boton,
    VoidCallback? onBoton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
            const SizedBox(height: 18),
            Text(titulo,
                style: const TextStyle(
                    color: Colores.text, fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitulo,
                style: const TextStyle(color: Colores.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            if (boton != null && onBoton != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onBoton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(boton,
                    style: const TextStyle(
                        color: Colores.text, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
