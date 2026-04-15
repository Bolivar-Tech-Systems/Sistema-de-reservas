import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaHorario extends StatefulWidget {
  final String recurso;
  final String imagen;
  final int reservaId; // <-- nuevo parámetro

  const PantallaHorario({
    required this.recurso,
    required this.imagen,
    required this.reservaId,
    super.key,
  });

  @override
  State<PantallaHorario> createState() => _PantallaHorarioState();
}

class _PantallaHorarioState extends State<PantallaHorario> {
  DateTime? _fecha;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  bool _cargando = false;

  Future<void> _seleccionarFecha() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colores.primary,
            surface: Colores.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (nuevaFecha != null) setState(() => _fecha = nuevaFecha);
  }

  Future<void> _seleccionarHoraInicio() async {
    final TimeOfDay? nueva = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colores.primary,
            surface: Colores.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (nueva != null) setState(() => _horaInicio = nueva);
  }

  Future<void> _seleccionarHoraFin() async {
    final TimeOfDay? nueva = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colores.primary,
            surface: Colores.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (nueva != null) setState(() => _horaFin = nueva);
  }

  String _formatearHora(TimeOfDay hora) {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  String _formatearFecha(DateTime fecha) {
    final y = fecha.year;
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _reservar() async {
    setState(() => _cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/reservas/reserva_usuario/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "reserva_id": widget.reservaId,
          "fecha_inicio": _formatearFecha(_fecha!),
          "fecha_fin": _formatearFecha(_fecha!),
          "hora_inicio": _formatearHora(_horaInicio!),
          "hora_fin": _formatearHora(_horaFin!),
          "estado": "pendiente",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reserva creada correctamente")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al reservar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo conectar al servidor")),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  bool get _formularioCompleto =>
      _fecha != null && _horaInicio != null && _horaFin != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colores.background, Colors.black],
          ),
        ),
        padding: const EdgeInsets.only(top: 20, left: 10, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Header
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Horario disponible',
                    style: TextStyle(
                      color: Colores.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tarjeta recurso
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colores.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.imagen,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.recurso,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colores.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Selecciona una hora disponible",
                style: TextStyle(color: Colores.text, fontSize: 15),
              ),

              const SizedBox(height: 20),

              // Campo fecha
              GestureDetector(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colores.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _fecha == null
                            ? "Seleccionar fecha"
                            : "${_fecha!.day}/${_fecha!.month}/${_fecha!.year}",
                        style: TextStyle(
                          color: _fecha == null ? Colores.textSecondary : Colores.text,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hora inicio y fin en fila
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _seleccionarHoraInicio,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: Colores.primary, size: 18),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _horaInicio == null ? "Hora inicio" : _horaInicio!.format(context),
                                style: TextStyle(
                                  color: _horaInicio == null ? Colores.textSecondary : Colores.text,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _seleccionarHoraFin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, color: Colores.primary, size: 18),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _horaFin == null ? "Hora fin" : _horaFin!.format(context),
                                style: TextStyle(
                                  color: _horaFin == null ? Colores.textSecondary : Colores.text,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Botón verificar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.surface,
                    foregroundColor: Colores.text,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colores.primary),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colores.primary, size: 18),
                      const SizedBox(width: 8),
                      Text("Verificar base de datos", style: TextStyle(color: Colores.primary)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón reservar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.primaryDark,
                    foregroundColor: Colores.text,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    disabledBackgroundColor: Colores.surface,
                    disabledForegroundColor: Colores.textSecondary,
                  ),
                  onPressed: _formularioCompleto && !_cargando ? _reservar : null,
                  child: _cargando
                      ? CircularProgressIndicator(color: Colores.primary)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _formularioCompleto
                                  ? Icons.check_circle_outline
                                  : Icons.lock_outline,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text("Reservar"),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}