import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import '../services/notificacion_services.dart';
import 'PagoWompi.dart';

class PantallaHorario extends StatefulWidget {
  final int recursoId;
  final String idUsuario;

  const PantallaHorario({
    super.key,
    required this.recursoId,
    required this.idUsuario,
  });

  @override
  State<PantallaHorario> createState() => _PantallaHorarioState();
}

class _PantallaHorarioState extends State<PantallaHorario> {
  // ── Estado ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _disponibilidades = [];
  List<Map<String, dynamic>> _reservasExistentes = [];
  bool _cargandoDisp = true;
  String _errorDisp = '';

  Map<String, dynamic>? _dispSeleccionada; // bloque de disponibilidad elegido
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  bool _reservando = false;
  String _errorReserva = '';

  // ── Reseñas ─────────────────────────────────────────────────────
  List<Map<String, dynamic>> _resenas = [];
  int _miCalificacion = 0;
  final _comentarioCtrl = TextEditingController();
  bool _enviandoResena = false;

  // ── Detalle del Recurso ──────────────────────────────────────────
  Map<String, dynamic>? _recursoDetalle;
  bool _cargandoDetalle = true;
  String _errorDetalle = '';

  // ── Init ───────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _cargarRecursoDetalle();
    _cargarDisponibilidades();
    _cargarReservasExistentes();
    _cargarResenas();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  // ── API: cargar detalle del recurso ──────────────────────────────────
  Future<void> _cargarRecursoDetalle() async {
    setState(() {
      _cargandoDetalle = true;
      _errorDetalle = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/${widget.recursoId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          _recursoDetalle = jsonDecode(res.body);
          _cargandoDetalle = false;
        });
      } else {
        setState(() {
          _errorDetalle = 'No se pudo cargar el detalle del recurso';
          _cargandoDetalle = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorDetalle = 'Error de red al cargar detalle';
          _cargandoDetalle = false;
        });
      }
    }
  }

  // ── API: cargar disponibilidades ───────────────────────────────────
  Future<void> _cargarDisponibilidades() async {
    setState(() { _cargandoDisp = true; _errorDisp = ''; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final res = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/reservas/disponibilidad/recurso/${widget.recursoId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        // Filtramos solo los disponibles
        final disponibles = data
            .map((d) => Map<String, dynamic>.from(d as Map))
            .where((d) => d['es_disponible'] == true)
            .toList();

        setState(() {
          _disponibilidades = disponibles;
          _cargandoDisp = false;
        });
      } else {
        setState(() {
          _errorDisp = 'No se pudo cargar la disponibilidad (${res.statusCode})';
          _cargandoDisp = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorDisp = 'Sin conexión al servidor';
          _cargandoDisp = false;
        });
      }
    }
  }

  Future<void> _cargarReservasExistentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/recurso/${widget.recursoId}/reservas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _reservasExistentes = data
                .map((r) => Map<String, dynamic>.from(r as Map))
                .where((r) => r['estado'] != 'Cancelado')
                .toList();
          });
        }
      }
    } catch (_) {}
  }

  // ── API: crear reserva ─────────────────────────────────────────────
  Future<void> _confirmarReserva() async {
    if (_dispSeleccionada == null || _horaInicio == null || _horaFin == null) return;

    // Validar que las horas estén dentro del bloque
    final limiteInicio = _parseHora(_dispSeleccionada!['hora_inicio']);
    final limiteFin    = _parseHora(_dispSeleccionada!['hora_fin']);

    if (_horaInicio!.hour * 60 + _horaInicio!.minute <
        limiteInicio.hour * 60 + limiteInicio.minute) {
      setState(() => _errorReserva =
          'La hora de inicio es anterior a la disponibilidad del recurso');
      return;
    }
    if (_horaFin!.hour * 60 + _horaFin!.minute >
        limiteFin.hour * 60 + limiteFin.minute) {
      setState(() => _errorReserva =
          'La hora de fin supera el límite de disponibilidad');
      return;
    }
    if (_horaInicio!.hour * 60 + _horaInicio!.minute >=
        _horaFin!.hour * 60 + _horaFin!.minute) {
      setState(() => _errorReserva = 'La hora de inicio debe ser antes de la hora de fin');
      return;
    }

    setState(() { _reservando = true; _errorReserva = ''; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final Map<String, dynamic> body = {
        // El schema usa alias: recurso_id → "reserva_id" en JSON
        'reserva_id': widget.recursoId,
        'fecha_inicio': _dispSeleccionada!['fecha_inicio'],
        'fecha_fin': _dispSeleccionada!['fecha_fin'],
        'hora_inicio': _formatHora(_horaInicio!),
        'hora_fin': _formatHora(_horaFin!),
        'estado': 'Pendiente',
      };

      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/reservas/reserva_usuario/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {

        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reserva creada correctamente!')),
        );
      } else {
        // Mostrar el mensaje de error del backend
        String msg = 'Error al crear la reserva (${res.statusCode})';
        try {
          final err = jsonDecode(res.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        setState(() { _errorReserva = msg; _reservando = false; });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorReserva = 'Sin conexión al servidor';
          _reservando = false;
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────
  TimeOfDay _parseHora(String? h) {
    if (h == null || h.isEmpty) return const TimeOfDay(hour: 0, minute: 0);
    final partes = h.split(':');
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 0,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  String _formatHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatFechaLegible(String? f) {
    if (f == null || f.isEmpty) return '—';
    try {
      final p = f.split('-');
      const meses = [
        '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      final mes = int.tryParse(p[1]) ?? 0;
      return '${p[2]} ${meses[mes]} ${p[0]}';
    } catch (_) { return f; }
  }

  String _formatHoraStr(String? h) {
    if (h == null || h.length < 5) return h ?? '—';
    return h.substring(0, 5);
  }

  int _minutosDisponibles(Map<String, dynamic> d) {
    final ini = _parseHora(d['hora_inicio']?.toString());
    final fin = _parseHora(d['hora_fin']?.toString());
    return (fin.hour * 60 + fin.minute) - (ini.hour * 60 + ini.minute);
  }

  String _duracionStr(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  bool get _formularioCompleto =>
      _dispSeleccionada != null && _horaInicio != null && _horaFin != null;

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) => showTimePicker(
        context: context,
        initialTime: initial,
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colores.primary,
              surface: Colores.surfaceAlt,
            ),
          ),
          child: child!,
        ),
      );

  // ── UI ─────────────────────────────────────────────────────────────
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
            children: [
              _buildHeader(),
              Expanded(
                child: _cargandoDisp
                    ? const Center(
                        child: CircularProgressIndicator(color: Colores.primary))
                    : (_errorDisp.isNotEmpty || _errorDetalle.isNotEmpty)
                        ? _buildError()
                        : _disponibilidades.isEmpty
                            ? _buildSinDisponibilidad()
                            : _buildContenido(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nueva reserva',
                  style: TextStyle(
                      color: Colores.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text('Selecciona un horario disponible',
                  style: TextStyle(
                      color: Colores.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final msg = _errorDisp.isNotEmpty ? _errorDisp : _errorDetalle;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Colores.textMuted, size: 52),
            const SizedBox(height: 14),
            Text(msg,
                style: const TextStyle(
                    color: Colores.textSecondary, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _cargarRecursoDetalle();
                _cargarDisponibilidades();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar',
                  style: TextStyle(color: Colores.text)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinDisponibilidad() {
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
              child: const Icon(Icons.event_busy_outlined,
                  color: Colores.textMuted, size: 48),
            ),
            const SizedBox(height: 18),
            const Text('Sin disponibilidad',
                style: TextStyle(
                    color: Colores.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Este recurso no tiene horarios habilitados por el administrador.',
              style: TextStyle(color: Colores.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _cargarDisponibilidades,
              child: const Text('Actualizar',
                  style: TextStyle(
                      color: Colores.primary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGaleriaRecurso(),
          _buildAmenidadesRecurso(),
          // ── Paso 1: elegir bloque ────────────────────────────────
          _labelSeccion('1. Elige un horario disponible'),
          const SizedBox(height: 10),
          ..._disponibilidades.map((d) => _buildDispCard(d)),

          if (_dispSeleccionada != null) ...[
            const SizedBox(height: 20),
            _buildOcupacionesWidget(),

            // ── Paso 2: ajustar horas dentro del bloque ──────────
            _labelSeccion('2. Ajusta tu hora de entrada y salida'),
            const SizedBox(height: 4),
            Text(
              'Debe estar entre ${_formatHoraStr(_dispSeleccionada!['hora_inicio']?.toString())} y ${_formatHoraStr(_dispSeleccionada!['hora_fin']?.toString())}',
              style: const TextStyle(color: Colores.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _selectorHora(
                    label: 'Entrada',
                    icon: Icons.login_rounded,
                    valor: _horaInicio != null
                        ? _horaInicio!.format(context)
                        : 'Seleccionar',
                    seleccionado: _horaInicio != null,
                    onTap: () async {
                      final limIni = _parseHora(
                          _dispSeleccionada!['hora_inicio']?.toString());
                      final t = await _pickTime(limIni);
                      if (t != null) setState(() => _horaInicio = t);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _selectorHora(
                    label: 'Salida',
                    icon: Icons.logout_rounded,
                    valor: _horaFin != null
                        ? _horaFin!.format(context)
                        : 'Seleccionar',
                    seleccionado: _horaFin != null,
                    onTap: () async {
                      final limFin = _parseHora(
                          _dispSeleccionada!['hora_fin']?.toString());
                      final t = await _pickTime(
                          _horaInicio ?? limFin);
                      if (t != null) setState(() => _horaFin = t);
                    },
                  ),
                ),
              ],
            ),

            // Resumen duración + precio
            if (_horaInicio != null && _horaFin != null)
              _buildResumen(),
          ],

          const SizedBox(height: 24),

          // ── Error ────────────────────────────────────────────────
          if (_errorReserva.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colores.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colores.danger.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colores.danger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_errorReserva,
                        style: const TextStyle(
                            color: Colores.danger, fontSize: 13)),
                  ),
                ],
              ),
            ),

          // ── Botón confirmar ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _formularioCompleto
                    ? Colores.primaryDark
                    : Colores.surfaceAlt,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _formularioCompleto && !_reservando
                  ? _confirmarReserva
                  : null,
              child: _reservando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colores.primary, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _formularioCompleto
                              ? Icons.check_circle_rounded
                              : Icons.lock_rounded,
                          size: 18,
                          color: _formularioCompleto
                              ? Colores.text
                              : Colores.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confirmar reserva',
                          style: TextStyle(
                            color: _formularioCompleto
                                ? Colores.text
                                : Colores.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // ── Sección Reseñas ────────────────────────────────────
          const SizedBox(height: 28),
          _labelSeccion('Reseñas'),
          const SizedBox(height: 10),
          _buildFormResena(),
          const SizedBox(height: 12),
          ..._resenas.map((r) => _buildResenaCard(r)),
          if (_resenas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Aún no hay reseñas para este recurso.',
                  style: TextStyle(color: Colores.textMuted, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildGaleriaRecurso() {
    if (_cargandoDetalle) {
      return Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colores.primary),
        ),
      );
    }

    if (_recursoDetalle == null) return const SizedBox.shrink();

    final List<dynamic> fotosRaw = _recursoDetalle!['fotos'] ?? [];
    final fotoPrincipal = _recursoDetalle!['foto_principal']?.toString() ?? '';
    final List<String> urls = [];

    if (fotoPrincipal.isNotEmpty) {
      urls.add(fotoPrincipal);
    }
    for (var f in fotosRaw) {
      final url = f['url']?.toString() ?? '';
      if (url.isNotEmpty && url != fotoPrincipal) {
        urls.add(url);
      }
    }

    if (urls.isEmpty) {
      final nombre = _recursoDetalle!['name']?.toString() ?? '?';
      final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
      return Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colores.primaryDark.withOpacity(0.6),
              Colores.surfaceAlt,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colores.border),
        ),
        child: Center(
          child: Text(
            inicial,
            style: const TextStyle(
              color: Colores.text,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 16),
      child: PageView.builder(
        itemCount: urls.length,
        itemBuilder: (context, index) {
          final url = urls[index];
          final fullUrl = url.startsWith('http') ? url : '${AppConfig.baseUrl}/images/$url';
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colores.border),
              image: DecorationImage(
                image: NetworkImage(fullUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmenidadesRecurso() {
    if (_cargandoDetalle || _recursoDetalle == null) return const SizedBox.shrink();

    final List<dynamic> amenidades = _recursoDetalle!['amenidades'] ?? [];
    if (amenidades.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelSeccion('Amenidades del recurso'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenidades.map((a) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colores.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colores.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colores.success, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    a['nombre']?.toString() ?? '',
                    style: const TextStyle(color: Colores.text, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildOcupacionesWidget() {
    if (_dispSeleccionada == null) return const SizedBox.shrink();
    final fecha = _dispSeleccionada!['fecha_inicio']?.toString();
    final ocupadas = _reservasExistentes.where((r) => r['fecha_inicio']?.toString() == fecha).toList();
    if (ocupadas.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
            SizedBox(width: 6),
            Text(
              'Horarios ya ocupados en esta fecha:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ocupadas.map((r) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                '${_formatHoraStr(r['hora_inicio']?.toString())} – ${_formatHoraStr(r['hora_fin']?.toString())}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Card de bloque de disponibilidad ──────────────────────────────
  Widget _buildDispCard(Map<String, dynamic> d) {
    final seleccionado = _dispSeleccionada == d;
    final minutos = _minutosDisponibles(d);
    final precio = d['precio_especial'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _dispSeleccionada = d;
          _horaInicio = null;
          _horaFin = null;
          _errorReserva = '';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado
              ? Colores.primaryDark.withOpacity(0.25)
              : Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? Colores.primary : Colores.border,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio visual
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: seleccionado ? Colores.primary : Colores.border,
                  width: 2,
                ),
                color: seleccionado
                    ? Colores.primary
                    : Colors.transparent,
              ),
              child: seleccionado
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colores.icon),
                      const SizedBox(width: 4),
                      Text(
                        d['fecha_inicio'] == d['fecha_fin']
                            ? _formatFechaLegible(
                                d['fecha_inicio']?.toString())
                            : '${_formatFechaLegible(d['fecha_inicio']?.toString())} – ${_formatFechaLegible(d['fecha_fin']?.toString())}',
                        style: const TextStyle(
                            color: Colores.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Hora
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: Colores.icon),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatHoraStr(d['hora_inicio']?.toString())} – ${_formatHoraStr(d['hora_fin']?.toString())}',
                        style: const TextStyle(
                            color: Colores.textSecondary,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colores.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _duracionStr(minutos),
                          style: const TextStyle(
                              color: Colores.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Precio especial si existe
            if (precio != null)
              Column(
                children: [
                  Text(
                    '\$${(precio as num).toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colores.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                  ),
                  const Text('tarifa especial',
                      style: TextStyle(
                          color: Colores.textMuted, fontSize: 9)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    final ini = _horaInicio!.hour * 60 + _horaInicio!.minute;
    final fin = _horaFin!.hour * 60 + _horaFin!.minute;
    final diff = fin - ini;

    if (diff <= 0) return const SizedBox.shrink();

    double precioPorHora = 0.0;
    if (_recursoDetalle != null && _recursoDetalle!['precio_por_hora'] != null) {
      precioPorHora = (_recursoDetalle!['precio_por_hora'] as num).toDouble();
    }
    final total = precioPorHora * (diff / 60.0);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colores.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colores.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: Colores.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Duración: ${_duracionStr(diff)}',
                  style: const TextStyle(
                      color: Colores.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (precioPorHora > 0)
              Text(
                'Total: \$${total.toStringAsFixed(0)} COP',
                style: const TextStyle(
                    color: Colores.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
          ],
        ),
      ),
    );
  }

  // ── Widget selector hora ───────────────────────────────────────────
  Widget _selectorHora({
    required String label,
    required IconData icon,
    required String valor,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado
              ? Colores.primaryDark.withOpacity(0.2)
              : Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado
                ? Colores.primary.withOpacity(0.5)
                : Colores.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colores.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon,
                    color: seleccionado
                        ? Colores.primary
                        : Colores.icon,
                    size: 14),
                const SizedBox(width: 6),
                Text(
                  valor,
                  style: TextStyle(
                    color: seleccionado
                        ? Colores.text
                        : Colores.textSecondary,
                    fontSize: 14,
                    fontWeight: seleccionado
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelSeccion(String texto) => Text(
        texto,
        style: const TextStyle(
          color: Colores.text,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      );

  // ── Reseñas: API ─────────────────────────────────────────────────
  Future<void> _cargarResenas() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/resenas/recurso/${widget.recursoId}'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (mounted) {
          setState(() => _resenas = data.cast<Map<String, dynamic>>());
        }
      }
    } catch (_) {}
  }

  Future<void> _enviarResena() async {
    if (_miCalificacion == 0) return;
    setState(() => _enviandoResena = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final userId = int.tryParse(prefs.getString('id_usuario') ?? '') ?? 0;
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/resenas/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recurso_id': widget.recursoId,
          'usuario_id': userId,
          'calificacion': _miCalificacion,
          'comentario': _comentarioCtrl.text.trim().isEmpty
              ? null
              : _comentarioCtrl.text.trim(),
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        _comentarioCtrl.clear();
        setState(() => _miCalificacion = 0);
        _cargarResenas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña enviada')),
        );
      } else {
        String msg = 'Error al enviar reseña';
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
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviandoResena = false);
    }
  }

  Widget _buildFormResena() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deja tu reseña',
              style: TextStyle(color: Colores.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          // Estrellas
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _miCalificacion = star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    star <= _miCalificacion
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: star <= _miCalificacion
                        ? Colors.orange
                        : Colores.textMuted,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _comentarioCtrl,
            style: const TextStyle(color: Colores.text, fontSize: 13),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Comentario (opcional)',
              hintStyle: const TextStyle(color: Colores.textMuted, fontSize: 13),
              filled: true,
              fillColor: Colores.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colores.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colores.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colores.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _miCalificacion > 0 && !_enviandoResena ? _enviarResena : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _miCalificacion > 0 ? Colores.primaryDark : Colores.surfaceAlt,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _enviandoResena
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colores.text))
                  : Text('Enviar reseña',
                      style: TextStyle(
                        color: _miCalificacion > 0 ? Colores.text : Colores.textMuted,
                        fontWeight: FontWeight.w700,
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResenaCard(Map<String, dynamic> r) {
    final calificacion = r['calificacion'] ?? 0;
    final comentario = r['comentario'] ?? '';
    final fecha = r['created_at']?.toString() ?? '';
    String fechaStr = '';
    try {
      final dt = DateTime.parse(fecha);
      const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      fechaStr = '${dt.day} ${meses[dt.month]} ${dt.year}';
    } catch (_) {}

    final usuario = r['usuario'] as Map<String, dynamic>?;
    final nombreUsuario = usuario != null
        ? (usuario['name'] ?? usuario['nombre'] ?? 'Usuario')
        : 'Usuario';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < (calificacion as int) ? Icons.star_rounded : Icons.star_border_rounded,
                color: i < calificacion ? Colors.orange : Colores.textMuted,
                size: 14,
              )),
              const Spacer(),
              if (fechaStr.isNotEmpty)
                Text(fechaStr,
                    style: const TextStyle(color: Colores.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colores.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Colores.primary, size: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                nombreUsuario,
                style: const TextStyle(
                  color: Colores.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (comentario.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                comentario.toString(),
                style: const TextStyle(color: Colores.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
