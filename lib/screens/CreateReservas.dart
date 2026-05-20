import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class PantallaCreateReserva extends StatefulWidget {
  const PantallaCreateReserva({super.key});

  @override
  State<PantallaCreateReserva> createState() => _PantallaCreateReservaState();
}

class _PantallaCreateReservaState extends State<PantallaCreateReserva> {
  final _nombre      = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio      = TextEditingController();
  final _capacidad   = TextEditingController();

  // ── Disponibilidad Inicial ─────────────────────────────────────────
  bool _crearDispInicial = true;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _horaFin = const TimeOfDay(hour: 18, minute: 0);

  String? _errorMSG;
  bool _cargando = false;

  File? _imagenSeleccionada;
  Uint8List? _imagenBytes;
  String? _imagenNombre;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Default dates: today and one month from today
    final hoy = DateTime.now();
    _fechaInicio = hoy;
    _fechaFin = hoy.add(const Duration(days: 30));
  }

  // ── Seleccionar imagen ─────────────────────────────────────────────
  Future<void> _seleccionarImagen() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imagenSeleccionada = File(picked.path);
        _imagenBytes = bytes;
        _imagenNombre = picked.name;
      });
    }
  }

  // ── Formateadores ──────────────────────────────────────────────────
  String _fmtFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  // ── Crear recurso ──────────────────────────────────────────────────
  Future<void> _crearRecurso() async {
    if (_nombre.text.trim().isEmpty) {
      setState(() => _errorMSG = 'El nombre del recurso es obligatorio');
      return;
    }

    if (_crearDispInicial) {
      if (_fechaInicio == null || _fechaFin == null || _horaInicio == null || _horaFin == null) {
        setState(() => _errorMSG = 'Define las fechas y horas de disponibilidad');
        return;
      }
      final iniMin = _horaInicio!.hour * 60 + _horaInicio!.minute;
      final finMin = _horaFin!.hour * 60 + _horaFin!.minute;
      if (iniMin >= finMin) {
        setState(() => _errorMSG = 'La hora de inicio debe ser anterior a la hora de fin');
        return;
      }
      if (_fechaInicio!.isAfter(_fechaFin!)) {
        setState(() => _errorMSG = 'La fecha de inicio debe ser anterior a la fecha de fin');
        return;
      }
    }

    setState(() { _cargando = true; _errorMSG = null; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isEmpty) {
        setState(() => _errorMSG = 'Sesión expirada, inicia sesión nuevamente');
        return;
      }

      // Body del recurso — usa alias "name" y "description"
      final Map<String, dynamic> bodyMap = {
        'name': _nombre.text.trim(),
        'description': _descripcion.text.trim(),
        'es_visible': true,
      };

      // Precio por hora (opcional)
      if (_precio.text.trim().isNotEmpty) {
        final p = double.tryParse(_precio.text.trim());
        if (p != null) bodyMap['precio_por_hora'] = p;
      }

      // Capacidad (opcional)
      if (_capacidad.text.trim().isNotEmpty) {
        final c = int.tryParse(_capacidad.text.trim());
        if (c != null) bodyMap['capacidad'] = c;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/reservas/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String msg = 'Error al crear (${response.statusCode})';
        try {
          final err = jsonDecode(response.body);
          msg = err['detail'] ?? msg;
        } catch (_) {}
        setState(() => _errorMSG = msg);
        return;
      }

      final recursoData = jsonDecode(response.body);
      final int recursoId = recursoData['id'];

      // Subir imagen si seleccionó una
      if (_imagenSeleccionada != null && _imagenBytes != null) {
        try {
          final fileName = _imagenNombre ?? 'imagen.jpg';
          final ext = fileName.split('.').last.toLowerCase();
          final mimeType = ext == 'png' ? 'png' : 'jpeg';

          final uploadRequest = http.MultipartRequest(
            'POST',
            Uri.parse('${AppConfig.baseUrl}/images/upload'),
          );
          uploadRequest.headers['Authorization'] = 'Bearer $token';
          uploadRequest.files.add(
            http.MultipartFile.fromBytes(
              'file',
              _imagenBytes!,
              filename: fileName,
              contentType: MediaType('image', mimeType),
            ),
          );
          uploadRequest.fields['file_name'] = fileName;
          uploadRequest.fields['reserva_id'] = recursoId.toString();

          await uploadRequest.send();
        } catch (_) {
          // Si falla la imagen no bloqueamos el flujo
        }
      }

      // Crear disponibilidad inicial si está activada
      if (_crearDispInicial) {
        final Map<String, dynamic> dispBody = {
          'reserva_id': recursoId,
          'fecha_inicio': _fmtFecha(_fechaInicio!),
          'fecha_fin': _fmtFecha(_fechaFin!),
          'hora_inicio': _fmtHora(_horaInicio!),
          'hora_fin': _fmtHora(_horaFin!),
          'es_disponible': true,
          'cantidad_disponible': 1,
        };

        await http.post(
          Uri.parse('${AppConfig.baseUrl}/reservas/disponibilidad/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(dispBody),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      setState(() => _errorMSG = 'No se pudo conectar al servidor');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ── UI Helpers ─────────────────────────────────────────────────────
  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
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
                        Text('Crear recurso',
                            style: TextStyle(
                                color: Colores.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        Text('Información del nuevo recurso',
                            style: TextStyle(
                                color: Colores.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Campos de texto ──────────────────────────────
                _inputField(
                  controller: _nombre,
                  label: 'Nombre del recurso *',
                  icon: Icons.label_outline_rounded,
                ),
                const SizedBox(height: 12),

                // Descripción multiline
                TextField(
                  controller: _descripcion,
                  style: const TextStyle(color: Colores.text, fontSize: 14),
                  maxLines: 3,
                  decoration: _inputDecoration(
                    label: 'Descripción (opcional)',
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 12),

                // Precio y capacidad en fila
                Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        controller: _precio,
                        label: 'Precio/hora',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        hint: '0.00',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _inputField(
                        controller: _capacidad,
                        label: 'Capacidad',
                        icon: Icons.people_outline_rounded,
                        keyboardType: TextInputType.number,
                        hint: 'personas',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Disponibilidad inicial switch ──────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colores.surfaceAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colores.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Colores.primary, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habilitar disponibilidad',
                              style: TextStyle(color: Colores.text, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Define el horario de reserva ahora',
                              style: TextStyle(color: Colores.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _crearDispInicial,
                        activeColor: Colores.primary,
                        activeTrackColor: Colores.primary.withOpacity(0.2),
                        inactiveThumbColor: Colores.textMuted,
                        inactiveTrackColor: Colores.border,
                        onChanged: (val) => setState(() => _crearDispInicial = val),
                      ),
                    ],
                  ),
                ),

                if (_crearDispInicial) ...[
                  const SizedBox(height: 16),
                  // Rango de Fechas
                  Row(
                    children: [
                      Expanded(
                        child: _selectorBoton(
                          label: 'Desde (Fecha)',
                          valor: _fechaInicio != null ? _fmtFecha(_fechaInicio!) : 'Seleccionar',
                          icon: Icons.calendar_today_outlined,
                          onTap: () async {
                            final d = await _pickDate(_fechaInicio ?? DateTime.now());
                            if (d != null) setState(() => _fechaInicio = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectorBoton(
                          label: 'Hasta (Fecha)',
                          valor: _fechaFin != null ? _fmtFecha(_fechaFin!) : 'Seleccionar',
                          icon: Icons.calendar_today_rounded,
                          onTap: () async {
                            final d = await _pickDate(_fechaFin ?? DateTime.now());
                            if (d != null) setState(() => _fechaFin = d);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Horarios
                  Row(
                    children: [
                      Expanded(
                        child: _selectorBoton(
                          label: 'Hora Inicio',
                          valor: _horaInicio != null ? _horaInicio!.format(context) : 'Seleccionar',
                          icon: Icons.access_time_rounded,
                          onTap: () async {
                            final t = await _pickTime(_horaInicio ?? const TimeOfDay(hour: 8, minute: 0));
                            if (t != null) setState(() => _horaInicio = t);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectorBoton(
                          label: 'Hora Fin',
                          valor: _horaFin != null ? _horaFin!.format(context) : 'Seleccionar',
                          icon: Icons.access_time_filled_rounded,
                          onTap: () async {
                            final t = await _pickTime(_horaFin ?? const TimeOfDay(hour: 18, minute: 0));
                            if (t != null) setState(() => _horaFin = t);
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // ── Imagen ───────────────────────────────────────
                const Text('Imagen del recurso',
                    style: TextStyle(
                        color: Colores.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colores.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _imagenSeleccionada != null
                            ? Colores.primary
                            : Colores.border,
                        width: _imagenSeleccionada != null ? 1.5 : 1,
                      ),
                    ),
                    child: _imagenSeleccionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: kIsWeb
                                ? Image.memory(_imagenBytes!,
                                    fit: BoxFit.cover)
                                : Image.file(_imagenSeleccionada!,
                                    fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colores.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colores.primary,
                                    size: 28),
                              ),
                              const SizedBox(height: 10),
                              const Text('Toca para agregar una imagen',
                                  style: TextStyle(
                                      color: Colores.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              const Text('JPG o PNG',
                                  style: TextStyle(
                                      color: Colores.textMuted,
                                      fontSize: 11)),
                            ],
                          ),
                  ),
                ),

                if (_imagenSeleccionada != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _imagenSeleccionada = null;
                        _imagenBytes = null;
                        _imagenNombre = null;
                      }),
                      icon: const Icon(Icons.close_rounded,
                          color: Colores.danger, size: 15),
                      label: const Text('Quitar imagen',
                          style: TextStyle(
                              color: Colores.danger, fontSize: 12)),
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Error ────────────────────────────────────────
                if (_errorMSG != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 14),
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
                          child: Text(_errorMSG!,
                              style: const TextStyle(
                                  color: Colores.danger, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // ── Botón publicar ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _cargando ? null : _crearRecurso,
                    child: _cargando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colores.primary, strokeWidth: 2.5),
                          )
                        : const Text('Publicar recurso',
                            style: TextStyle(
                                color: Colores.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colores.textMuted, fontSize: 13),
      labelStyle:
          const TextStyle(color: Colores.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: Colores.primary, size: 18),
      filled: true,
      fillColor: Colores.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colores.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colores.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colores.primary),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colores.text, fontSize: 14),
      keyboardType: keyboardType,
      decoration: _inputDecoration(label: label, icon: icon, hint: hint),
    );
  }

  Widget _selectorBoton({
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
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colores.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colores.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
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
                          color: Colores.text, fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
