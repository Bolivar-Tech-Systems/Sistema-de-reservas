import 'package:flutter/material.dart';
import '../util/colores.dart';

class PantallaHorario extends StatefulWidget {
  final String recurso;
  final String imagen;

  const PantallaHorario({
    required this.recurso,
    required this.imagen,
    super.key,
  });

  @override
  State<PantallaHorario> createState() => _PantallaHorarioState();
}

class _PantallaHorarioState extends State<PantallaHorario> {
  DateTime? _fecha;
  TimeOfDay? _hora;

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

  Future<void> _seleccionarHora() async {
    final TimeOfDay? nuevaHora = await showTimePicker(
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
    if (nuevaHora != null) setState(() => _hora = nuevaHora);
  }

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
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: 20,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colores.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _fecha == null
                            ? "Seleccionar fecha"
                            : "${_fecha!.day}/${_fecha!.month}/${_fecha!.year}",
                        style: TextStyle(
                          color: _fecha == null
                              ? Colores.textSecondary
                              : Colores.text,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Campo hora
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _seleccionarHora,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: Colores.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _hora == null
                                    ? "Seleccionar hora"
                                    : _hora!.format(context),
                                style: TextStyle(
                                  color: _hora == null
                                      ? Colores.textSecondary
                                      : Colores.text,
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

              // Botón verificar base de datos
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
                      Text(
                        "Verificar base de datos",
                        style: TextStyle(color: Colores.primary),
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colores.surface,
                    disabledForegroundColor: Colores.textSecondary,
                  ),
                  onPressed: (_fecha == null || _hora == null) ? null : () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        (_fecha == null || _hora == null)
                            ? Icons.lock_outline
                            : Icons.check_circle_outline,
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
