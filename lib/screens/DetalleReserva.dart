import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaDetalleReserva extends StatefulWidget {
  // reserva contiene todos los campos de ReservaUsuario + nombre_recurso, foto_recurso, etc.
  final Map<String, dynamic> reserva;

  const PantallaDetalleReserva({required this.reserva, super.key});

  @override
  State<PantallaDetalleReserva> createState() =>
      _PantallaDetalleReservaState();
}

class _PantallaDetalleReservaState extends State<PantallaDetalleReserva> {
  bool _cargando = false;
  int _roleId = 0;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _roleId = prefs.getInt('role_id') ?? 0;
      });
    }
  }

  // ── API ────────────────────────────────────────────────────────────
  Future<void> cancelarReserva() async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http.delete(
        // El id de la ReservaUsuario es widget.reserva['id']
        Uri.parse('${AppConfig.baseUrl}/reservas/reserva_usuario/${widget.reserva['id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar: ${response.statusCode}')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> actualizarEstadoReserva(String nuevoEstado) async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final r = widget.reserva;
      final body = {
        'reserva_id': r['reserva_id'] ?? r['recurso_id'],
        'fecha_inicio': r['fecha_inicio'],
        'fecha_fin': r['fecha_fin'],
        'hora_inicio': r['hora_inicio'],
        'hora_fin': r['hora_fin'],
        'estado': nuevoEstado,
        'notas': r['notas'],
      };

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/reservas/reserva_usuario/${r['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva actualizada a $nuevoEstado')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.statusCode}')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _confirmarCancelacion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colores.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Cancelar reserva?',
            style: TextStyle(color: Colores.text, fontWeight: FontWeight.w800)),
        content: const Text(
          'Esta acción no se puede deshacer. La reserva quedará marcada como cancelada.',
          style: TextStyle(color: Colores.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver',
                style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cancelarReserva();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Sí, cancelar',
                style: TextStyle(color: Colores.text, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────
  Color _colorEstado(String e) {
    switch (e) {
      case 'activa':
      case 'confirmada': return Colores.success;
      case 'pendiente':  return Colores.warning;
      case 'cancelada':  return Colores.danger;
      default:           return Colores.textSecondary;
    }
  }

  String _formatFecha(String? f) {
    if (f == null || f.isEmpty) return 'No disponible';
    try {
      final p = f.split('-');
      return '${p[2]}/${p[1]}/${p[0]}';
    } catch (_) { return f; }
  }

  String _formatHora(String? h) {
    if (h == null || h.isEmpty) return '—';
    return h.length >= 5 ? h.substring(0, 5) : h;
  }

  int _calcularHoras() {
    try {
      final inicio = widget.reserva['hora_inicio']?.toString() ?? '';
      final fin    = widget.reserva['hora_fin']?.toString() ?? '';
      if (inicio.isEmpty || fin.isEmpty) return 0;
      final hI = int.parse(inicio.split(':')[0]);
      final mI = int.parse(inicio.split(':')[1]);
      final hF = int.parse(fin.split(':')[0]);
      final mF = int.parse(fin.split(':')[1]);
      return (hF * 60 + mF) - (hI * 60 + mI);
    } catch (_) { return 0; }
  }

  DateTime? _parseFecha(String? f) {
    if (f == null || f.isEmpty) return null;
    try {
      return DateTime.parse(f);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseHora(String? h) {
    if (h == null || h.isEmpty) return null;
    try {
      final parts = h.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarReservaAPI({
    required String fechaInicio,
    required String fechaFin,
    required String horaInicio,
    required String horaFin,
    required int cantidad,
    required String notas,
  }) async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final r = widget.reserva;
      final precio = r['precio_total'];
      final pph = r['precio_por_hora'];

      double? nuevoPrecioTotal;
      if (pph != null) {
        final pphDouble = double.tryParse(pph.toString()) ?? 0.0;
        final hI = int.parse(horaInicio.split(':')[0]);
        final mI = int.parse(horaInicio.split(':')[1]);
        final hF = int.parse(horaFin.split(':')[0]);
        final mF = int.parse(horaFin.split(':')[1]);
        final minutos = (hF * 60 + mF) - (hI * 60 + mI);
        if (minutos > 0) {
          nuevoPrecioTotal = (minutos / 60) * pphDouble;
        }
      } else if (precio != null) {
        final originalMinutos = _calcularHoras();
        if (originalMinutos > 0) {
          final estimatedPph = (double.tryParse(precio.toString()) ?? 0.0) / (originalMinutos / 60);
          final hI = int.parse(horaInicio.split(':')[0]);
          final mI = int.parse(horaInicio.split(':')[1]);
          final hF = int.parse(horaFin.split(':')[0]);
          final mF = int.parse(horaFin.split(':')[1]);
          final minutos = (hF * 60 + mF) - (hI * 60 + mI);
          if (minutos > 0) {
            nuevoPrecioTotal = (minutos / 60) * estimatedPph;
          }
        }
      }

      final body = {
        'reserva_id': r['reserva_id'] ?? r['recurso_id'],
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'cantidad': cantidad,
        'precio_total': nuevoPrecioTotal ?? precio,
        'estado': r['estado'],
        'notas': notas,
      };

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/reservas/reserva_usuario/${r['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva modificada correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        String msg = 'Error al actualizar: ${response.statusCode}';
        try {
          final err = jsonDecode(response.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarDialogoModificar() {
    final r = widget.reserva;
    
    DateTime selectedDate = _parseFecha(r['fecha_inicio']?.toString()) ?? DateTime.now();
    TimeOfDay selectedHoraInicio = _parseHora(r['hora_inicio']?.toString()) ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay selectedHoraFin = _parseHora(r['hora_fin']?.toString()) ?? const TimeOfDay(hour: 18, minute: 0);
    
    final notesController = TextEditingController(text: r['notas']?.toString() ?? '');
    final cantidadController = TextEditingController(text: (r['cantidad'] ?? 1).toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String formatTime(TimeOfDay t) {
              final h = t.hour.toString().padLeft(2, '0');
              final m = t.minute.toString().padLeft(2, '0');
              return '$h:$m';
            }

            String formatDate(DateTime d) {
              final day = d.day.toString().padLeft(2, '0');
              final month = d.month.toString().padLeft(2, '0');
              final year = d.year;
              return '$day/$month/$year';
            }

            return AlertDialog(
              backgroundColor: Colores.surfaceAlt,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text(
                'Modificar Reserva',
                style: TextStyle(color: Colores.text, fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FECHA',
                      style: TextStyle(color: Colores.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Colores.primary,
                                  onPrimary: Colors.white,
                                  surface: Colores.surfaceAlt,
                                  onSurface: Colores.text,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (d != null) {
                          setDialogState(() {
                            selectedDate = d;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formatDate(selectedDate), style: const TextStyle(color: Colores.text)),
                            const Icon(Icons.calendar_today_outlined, color: Colores.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HORA INICIO',
                                style: TextStyle(color: Colores.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: selectedHoraInicio,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Colores.primary,
                                            onPrimary: Colors.white,
                                            surface: Colores.surfaceAlt,
                                            onSurface: Colores.text,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (t != null) {
                                    setDialogState(() {
                                      selectedHoraInicio = t;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colores.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colores.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(formatTime(selectedHoraInicio), style: const TextStyle(color: Colores.text)),
                                      const Icon(Icons.access_time_rounded, color: Colores.primary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HORA FIN',
                                style: TextStyle(color: Colores.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: selectedHoraFin,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Colores.primary,
                                            onPrimary: Colors.white,
                                            surface: Colores.surfaceAlt,
                                            onSurface: Colores.text,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (t != null) {
                                    setDialogState(() {
                                      selectedHoraFin = t;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colores.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colores.border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(formatTime(selectedHoraFin), style: const TextStyle(color: Colores.text)),
                                      const Icon(Icons.access_time_rounded, color: Colores.primary, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'CANTIDAD DE PERSONAS / UNIDADES',
                      style: TextStyle(color: Colores.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cantidadController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colores.text, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colores.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colores.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colores.primary),
                        ),
                        prefixIcon: const Icon(Icons.people_alt_outlined, color: Colores.primary, size: 18),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'NOTAS / INDICACIONES',
                      style: TextStyle(color: Colores.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colores.text, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colores.surface,
                        hintText: 'Añade alguna nota o indicación para la reserva...',
                        hintStyle: const TextStyle(color: Colores.textMuted),
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colores.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colores.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colores.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final qty = int.tryParse(cantidadController.text.trim()) ?? 1;
                    if (qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
                      );
                      return;
                    }
                    
                    final iniMin = selectedHoraInicio.hour * 60 + selectedHoraInicio.minute;
                    final finMin = selectedHoraFin.hour * 60 + selectedHoraFin.minute;
                    if (iniMin >= finMin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('La hora de inicio debe ser anterior a la hora de fin')),
                      );
                      return;
                    }

                    final String fechaFmt = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                    final String horaIniFmt = formatTime(selectedHoraInicio);
                    final String horaFinFmt = formatTime(selectedHoraFin);

                    Navigator.pop(context);
                    actualizarReservaAPI(
                      fechaInicio: fechaFmt,
                      fechaFin: fechaFmt,
                      horaInicio: horaIniFmt,
                      horaFin: horaFinFmt,
                      cantidad: qty,
                      notas: notesController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r       = widget.reserva;
    final estado  = (r['estado'] ?? 'pendiente').toString().toLowerCase();
    final cancelada = estado == 'cancelada';
    final color   = _colorEstado(estado);
    final precio  = r['precio_total'];
    final pph     = r['precio_por_hora'];
    final foto    = r['foto_recurso'];
    final minutos = _calcularHoras();

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image con overlay ───────────────────────────
                _buildHeroHeader(foto, color, estado),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        r['nombre_recurso'] ?? r['name'] ?? 'Sin nombre',
                        style: const TextStyle(
                          color: Colores.text,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      if ((r['descripcion_recurso'] ?? r['description'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          r['descripcion_recurso'] ?? r['description'] ?? '',
                          style: const TextStyle(
                              color: Colores.textSecondary, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 22),

                      // ── Bloque información ───────────────────────
                      _seccionCard('Detalles de la reserva', [
                        _fila(Icons.confirmation_number_outlined, 'ID',
                            '#${r['id']}'),
                        _divider(),
                        _fila(Icons.calendar_today_outlined, 'Fecha',
                            _formatFecha(r['fecha_inicio']?.toString())),
                        _divider(),
                        _fila(Icons.access_time_rounded, 'Horario',
                            '${_formatHora(r['hora_inicio']?.toString())} – ${_formatHora(r['hora_fin']?.toString())}'),
                        if (minutos > 0) ...[
                          _divider(),
                          _fila(Icons.timer_outlined, 'Duración',
                              _formatMinutos(minutos)),
                        ],
                        if ((r['notas'] ?? '').toString().isNotEmpty) ...[
                          _divider(),
                          _fila(Icons.notes_rounded, 'Notas',
                              r['notas'].toString()),
                        ],
                      ]),

                      const SizedBox(height: 14),

                      // ── Bloque pago ──────────────────────────────
                      if (precio != null || pph != null)
                        _seccionCard('Resumen de pago', [
                          if (pph != null)
                            _fila(Icons.attach_money_rounded, 'Precio por hora',
                                '\$${(pph as num).toStringAsFixed(0)}'),
                          if (pph != null && minutos > 0) ...[
                            _divider(),
                            _fila(Icons.calculate_outlined, 'Cálculo',
                                '${(minutos / 60).toStringAsFixed(1)} h × \$${(pph as num).toStringAsFixed(0)}'),
                          ],
                          if (precio != null) ...[
                            if (pph != null) _divider(),
                            _fila(Icons.payments_rounded, 'Total',
                                '\$${(precio as num).toStringAsFixed(0)}',
                                valueColor: Colores.primary,
                                bold: true),
                          ],
                        ]),

                      const SizedBox(height: 28),

                      // ── Botones ──────────────────────────────────
                      if (_roleId == 1) ...[
                        // Admin Actions
                        if (!cancelada) ...[
                          _boton(
                            label: 'Modificar reserva',
                            icon: Icons.edit_outlined,
                            textColor: Colores.primary,
                            borderColor: Colores.primary,
                            bgColor: Colores.primary.withOpacity(0.08),
                            onTap: _mostrarDialogoModificar,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (estado == 'pendiente') ...[
                          _boton(
                            label: 'Aprobar reserva',
                            icon: Icons.check_circle_outline_rounded,
                            textColor: Colores.success,
                            borderColor: Colores.success,
                            bgColor: Colores.success.withOpacity(0.08),
                            loading: _cargando,
                            onTap: () => actualizarEstadoReserva('Confirmada'),
                          ),
                          const SizedBox(height: 12),
                          _boton(
                            label: 'Rechazar reserva',
                            icon: Icons.cancel_outlined,
                            textColor: Colores.danger,
                            borderColor: Colores.danger,
                            bgColor: Colores.danger.withOpacity(0.08),
                            loading: _cargando,
                            onTap: () => actualizarEstadoReserva('Cancelada'),
                          ),
                        ] else if (estado == 'confirmada') ...[
                          _boton(
                            label: 'Cancelar/Rechazar reserva',
                            icon: Icons.cancel_outlined,
                            textColor: Colores.danger,
                            borderColor: Colores.danger,
                            bgColor: Colores.danger.withOpacity(0.08),
                            loading: _cargando,
                            onTap: () => actualizarEstadoReserva('Cancelada'),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colores.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colores.danger.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_rounded,
                                    color: Colores.danger, size: 16),
                                SizedBox(width: 8),
                                Text('Esta reserva está cancelada',
                                    style: TextStyle(
                                        color: Colores.danger,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ]
                      ] else ...[
                        // User Actions
                        if (!cancelada) ...[
                          _boton(
                            label: 'Modificar reserva',
                            icon: Icons.edit_outlined,
                            textColor: Colores.primary,
                            borderColor: Colores.primary,
                            bgColor: Colores.primary.withOpacity(0.08),
                            onTap: _mostrarDialogoModificar,
                          ),
                          const SizedBox(height: 12),
                          _boton(
                            label: 'Cancelar reserva',
                            icon: Icons.cancel_outlined,
                            textColor: Colores.danger,
                            borderColor: Colores.danger,
                            bgColor: Colores.danger.withOpacity(0.08),
                            loading: _cargando,
                            onTap: _confirmarCancelacion,
                          ),
                        ] else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colores.danger.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colores.danger.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_rounded,
                                    color: Colores.danger, size: 16),
                                SizedBox(width: 8),
                                Text('Esta reserva está cancelada',
                                    style: TextStyle(
                                        color: Colores.danger,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                      ],
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

  // ── Hero ───────────────────────────────────────────────────────────
  Widget _buildHeroHeader(String? foto, Color color, String estado) {
    return Stack(
      children: [
        // Fondo imagen o gradiente de color de estado
        SizedBox(
          height: 200,
          width: double.infinity,
          child: foto != null && foto.isNotEmpty
              ? Image.network(foto, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _colorBg(color))
              : _colorBg(color),
        ),
        // Overlay gradiente
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // Back button + badge estado
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.6)),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorBg(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.primaryDark.withOpacity(0.6),
            color.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.domain_rounded,
            color: Colors.white.withOpacity(0.15), size: 80),
      ),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────────────
  Widget _seccionCard(String titulo, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(),
              style: const TextStyle(
                  color: Colores.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _fila(IconData icon, String label, String valor,
      {Color? valueColor, bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colores.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colores.primary, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colores.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(valor,
                  style: TextStyle(
                    color: valueColor ?? Colores.text,
                    fontSize: 14,
                    fontWeight:
                        bold ? FontWeight.w800 : FontWeight.w500,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: Colores.border, height: 1, thickness: 1),
      );

  Widget _boton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color borderColor,
    required Color bgColor,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor.withOpacity(0.5)),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: textColor, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Text(label,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatMinutos(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}
