import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaGestionDisponibilidad extends StatefulWidget {
  final int recursoId;
  final String recursoNombre;

  const PantallaGestionDisponibilidad({
    super.key,
    required this.recursoId,
    required this.recursoNombre,
  });

  @override
  State<PantallaGestionDisponibilidad> createState() =>
      _PantallaGestionDisponibilidadState();
}

class _PantallaGestionDisponibilidadState
    extends State<PantallaGestionDisponibilidad> {
  List<Map<String, dynamic>> _disponibilidades = [];
  bool _cargando = true;
  bool _creando = false;
  bool _eliminandoRecurso = false;
  String _error = '';
  int? _roleId;

  @override
  void initState() {
    super.initState();
    _cargarRoleId();
    _cargar();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> _cargarRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _roleId = prefs.getInt('role_id'));
    }
  }

  // ── Cargar disponibilidades existentes ──────────────────────────────
  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = ''; });
    try {
      final token = await _getToken();
      final res = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/reservas/disponibilidad/recurso/${widget.recursoId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _disponibilidades =
              data.map((d) => Map<String, dynamic>.from(d as Map)).toList();
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'Error ${res.statusCode}';
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Sin conexión'; _cargando = false; });
    }
  }

  // ── Crear nueva disponibilidad ─────────────────────────────────────
  Future<void> _crearDisponibilidad({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
  }) async {
    setState(() { _creando = true; _error = ''; });
    try {
      final token = await _getToken();
      final body = {
        'reserva_id': widget.recursoId, // alias de recurso_id
        'fecha_inicio': _fmtFecha(fechaInicio),
        'fecha_fin': _fmtFecha(fechaFin),
        'hora_inicio': _fmtHora(horaInicio),
        'hora_fin': _fmtHora(horaFin),
        'es_disponible': true,
        'cantidad_disponible': 1,
      };

      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/reservas/disponibilidad/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        _cargar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disponibilidad creada')),
        );
      } else {
        String msg = 'Error al crear';
        try {
          final err = jsonDecode(res.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        setState(() => _error = msg);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Sin conexión');
    } finally {
      if (mounted) setState(() => _creando = false);
    }
  }

  // ── Eliminar disponibilidad ────────────────────────────────────────
  Future<void> _eliminar(int id) async {
    try {
      final token = await _getToken();
      await http.delete(
        Uri.parse('${AppConfig.baseUrl}/reservas/disponibilidad/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (mounted) _cargar();
    } catch (_) {}
  }

  // ── Eliminar recurso completo (solo admin) ─────────────────────────
  Future<void> _eliminarRecurso() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colores.surfaceAlt,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar recurso?',
            style: TextStyle(
                color: Colores.text, fontWeight: FontWeight.w700)),
        content: const Text(
            'Esta acción es irreversible. Se eliminará el recurso y toda su disponibilidad.',
            style:
                TextStyle(color: Colores.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colores.text, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _eliminandoRecurso = true);
    try {
      final token = await _getToken();
      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/reservas/${widget.recursoId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recurso eliminado')),
        );
        Navigator.pop(context, true);
      } else {
        String msg = 'Error al eliminar recurso';
        try {
          final err = jsonDecode(res.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sin conexión')),
        );
      }
    } finally {
      if (mounted) setState(() => _eliminandoRecurso = false);
    }
  }

  // ── Formateo ───────────────────────────────────────────────────────
  String _fmtFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _fmtFechaLegible(String? f) {
    if (f == null) return '—';
    try {
      final p = f.split('-');
      const m = ['','Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
      return '${p[2]} ${m[int.parse(p[1])]}';
    } catch (_) { return f; }
  }

  String _fmtHoraStr(String? h) =>
      (h != null && h.length >= 5) ? h.substring(0, 5) : (h ?? '—');

  // ── Diálogo para crear ─────────────────────────────────────────────
  void _mostrarDialogoCrear() {
    DateTime? fechaIni;
    DateTime? fechaFin;
    TimeOfDay? horaIni;
    TimeOfDay? horaFin;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colores.surfaceAlt,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colores.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Agregar disponibilidad',
                      style: TextStyle(
                          color: Colores.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text(
                      'Define el rango de fechas y horas que estará habilitado.',
                      style: TextStyle(
                          color: Colores.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),

                  // Fecha inicio
                  _selectorModal(
                    label: 'Fecha inicio',
                    valor: fechaIni != null
                        ? _fmtFecha(fechaIni!)
                        : 'Seleccionar',
                    icon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (c, ch) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colores.primary,
                              surface: Colores.surfaceAlt,
                            ),
                          ),
                          child: ch!,
                        ),
                      );
                      if (d != null) setModalState(() { fechaIni = d; fechaFin ??= d; });
                    },
                  ),
                  const SizedBox(height: 10),

                  // Fecha fin
                  _selectorModal(
                    label: 'Fecha fin',
                    valor: fechaFin != null
                        ? _fmtFecha(fechaFin!)
                        : 'Seleccionar',
                    icon: Icons.calendar_today_outlined,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: fechaIni ?? DateTime.now(),
                        firstDate: fechaIni ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (c, ch) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colores.primary,
                              surface: Colores.surfaceAlt,
                            ),
                          ),
                          child: ch!,
                        ),
                      );
                      if (d != null) setModalState(() => fechaFin = d);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Horas
                  Row(
                    children: [
                      Expanded(
                        child: _selectorModal(
                          label: 'Hora inicio',
                          valor: horaIni != null
                              ? horaIni!.format(ctx)
                              : 'Inicio',
                          icon: Icons.access_time_rounded,
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 8, minute: 0),
                              builder: (c, ch) => Theme(
                                data: Theme.of(c).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colores.primary,
                                    surface: Colores.surfaceAlt,
                                  ),
                                ),
                                child: ch!,
                              ),
                            );
                            if (t != null) setModalState(() => horaIni = t);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selectorModal(
                          label: 'Hora fin',
                          valor: horaFin != null
                              ? horaFin!.format(ctx)
                              : 'Fin',
                          icon: Icons.access_time_filled_rounded,
                          onTap: () async {
                            final t = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 17, minute: 0),
                              builder: (c, ch) => Theme(
                                data: Theme.of(c).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colores.primary,
                                    surface: Colores.surfaceAlt,
                                  ),
                                ),
                                child: ch!,
                              ),
                            );
                            if (t != null) setModalState(() => horaFin = t);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (fechaIni != null &&
                                fechaFin != null &&
                                horaIni != null &&
                                horaFin != null)
                            ? Colores.primaryDark
                            : Colores.surfaceAlt,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: (fechaIni != null &&
                              fechaFin != null &&
                              horaIni != null &&
                              horaFin != null &&
                              !_creando)
                          ? () {
                              Navigator.pop(ctx);
                              _crearDisponibilidad(
                                fechaInicio: fechaIni!,
                                fechaFin: fechaFin!,
                                horaInicio: horaIni!,
                                horaFin: horaFin!,
                              );
                            }
                          : null,
                      child: Text(
                        'Habilitar horario',
                        style: TextStyle(
                          color: (fechaIni != null &&
                                  fechaFin != null &&
                                  horaIni != null &&
                                  horaFin != null)
                              ? Colores.text
                              : Colores.textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _selectorModal({
    required String label,
    required String valor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colores.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colores.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colores.primary, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colores.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(valor,
                    style: const TextStyle(
                        color: Colores.text, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colores.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colores.text, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Disponibilidad',
                              style: TextStyle(
                                  color: Colores.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          Text(widget.recursoNombre,
                              style: const TextStyle(
                                  color: Colores.textSecondary,
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    // Botón para agregar (Premium Header button)
                    GestureDetector(
                      onTap: _mostrarDialogoCrear,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colores.primaryDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.primary.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colores.text, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Error
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colores.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colores.danger.withOpacity(0.4)),
                    ),
                    child: Text(_error,
                        style: const TextStyle(
                            color: Colores.danger, fontSize: 13)),
                  ),
                ),

              // Body
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Colores.primary))
                    : _disponibilidades.isEmpty
                        ? _buildVacio()
                        : _buildLista(),
              ),

              // Botón eliminar recurso (solo admin)
              if (_roleId == 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _eliminandoRecurso ? null : _eliminarRecurso,
                      icon: _eliminandoRecurso
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colores.text))
                          : const Icon(Icons.delete_forever_rounded,
                              color: Colores.text, size: 20),
                      label: Text(
                        _eliminandoRecurso
                            ? 'Eliminando...'
                            : 'Eliminar recurso',
                        style: const TextStyle(
                          color: Colores.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.danger,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child: const Icon(Icons.schedule_rounded,
                  color: Colores.textMuted, size: 48),
            ),
            const SizedBox(height: 18),
            const Text('Sin horarios habilitados',
                style: TextStyle(
                    color: Colores.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Presiona el botón + para agregar ventanas de disponibilidad donde los usuarios puedan reservar.',
              style: TextStyle(color: Colores.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista() {
    return RefreshIndicator(
      color: Colores.primary,
      backgroundColor: Colores.surfaceAlt,
      onRefresh: _cargar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: _disponibilidades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildDispCard(_disponibilidades[i]),
      ),
    );
  }

  Widget _buildDispCard(Map<String, dynamic> d) {
    final activo = d['es_disponible'] == true;
    final id = d['id'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colores.border),
      ),
      child: Row(
        children: [
          // Indicador de estado
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activo ? Colores.success : Colores.danger,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (activo ? Colores.success : Colores.danger)
                      .withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colores.icon),
                    const SizedBox(width: 4),
                    Text(
                      d['fecha_inicio'] == d['fecha_fin']
                          ? _fmtFechaLegible(d['fecha_inicio']?.toString())
                          : '${_fmtFechaLegible(d['fecha_inicio']?.toString())} – ${_fmtFechaLegible(d['fecha_fin']?.toString())}',
                      style: const TextStyle(
                          color: Colores.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: Colores.icon),
                    const SizedBox(width: 4),
                    Text(
                      '${_fmtHoraStr(d['hora_inicio']?.toString())} – ${_fmtHoraStr(d['hora_fin']?.toString())}',
                      style: const TextStyle(
                          color: Colores.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Eliminar
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colores.surfaceAlt,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('¿Eliminar horario?',
                      style: TextStyle(
                          color: Colores.text, fontWeight: FontWeight.w700)),
                  content: const Text(
                      'Las reservas existentes en este horario no se afectarán.',
                      style:
                          TextStyle(color: Colores.textSecondary, fontSize: 14)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colores.textSecondary)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _eliminar(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.danger,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Eliminar',
                          style: TextStyle(
                              color: Colores.text, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colores.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colores.danger, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
