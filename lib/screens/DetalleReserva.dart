import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';

class PantallaDetalleReserva extends StatefulWidget {
  final Map<String, dynamic> reserva;

  const PantallaDetalleReserva({required this.reserva, super.key});

  @override
  State<PantallaDetalleReserva> createState() => _PantallaDetalleReservaState();
}

class _PantallaDetalleReservaState extends State<PantallaDetalleReserva> {
  bool _cargando = false;

  Future<void> cancelarReserva() async {
    setState(() => _cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.delete(
        Uri.parse("http://127.0.0.1:8000/reservas/reserva_usuario/${widget.reserva['id']}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reserva cancelada correctamente")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cancelar: ${response.statusCode}")),
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

  void _confirmarCancelacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colores.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "¿Cancelar reserva?", 
          style: TextStyle(color: Colores.text),
        ),
        content: Text(
          "Esta acción no se puede deshacer.",
          style: TextStyle(color: Colores.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Volver", style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cancelarReserva();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Sí, cancelar", style: TextStyle(color: Colores.text)),
          ),
        ],
      ),
    );
  }

  Widget _infoFila(IconData icono, String label, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colores.primary, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colores.textSecondary, fontSize: 12)),
              Text(valor, style: TextStyle(color: Colores.text, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearFechas() {
    final inicio = widget.reserva['fecha_inicio'];
    final fin = widget.reserva['fecha_fin'];
    if (inicio == null && fin == null) return 'No disponible';
    if (inicio != null && fin != null) return '$inicio → $fin';
    return inicio ?? fin ?? 'No disponible';
  }

  String _formatearHoras() {
    final inicio = widget.reserva['hora_inicio'];
    final fin = widget.reserva['hora_fin'];
    if (inicio == null && fin == null) return 'No disponible';
    if (inicio != null && fin != null) return '$inicio → $fin';
    return inicio ?? fin ?? 'No disponible';
  }

  @override
  Widget build(BuildContext context) {
    final reserva = widget.reserva;
    final estado = (reserva['estado'] ?? 'pendiente').toString().toLowerCase();
    final cancelada = estado == 'cancelada';

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
        padding: EdgeInsets.only(left: 10, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 55),

              // Header
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "Detalle de Reserva",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colores.text,
                    ),
                  ),
                ],
              ),

               SizedBox(height: 20),

              // Imagen del recurso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/nitro.jpg",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 20),

              // Badge de estado
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: estado == 'activa'
                      ? Colores.primaryDark
                      : estado == 'cancelada'
                          ? Colores.danger.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: estado == 'activa'
                        ? Colores.primary
                        : estado == 'cancelada'
                            ? Colores.danger
                            : Colors.orange,
                  ),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: estado == 'activa'
                        ? Colores.text
                        : estado == 'cancelada'
                            ? Colores.danger
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 16),

              Text(
                reserva['name'] ?? 'Sin nombre',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colores.text,
                ),
              ),

              SizedBox(height: 6),

              Text(
                reserva['description'] ?? '',
                style: TextStyle(fontSize: 14, color: Colores.textSecondary),
              ),

              SizedBox(height: 24),

              // Detalles
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colores.border),
                ),
                child: Column(
                  children: [
                    _infoFila(
                      Icons.calendar_today_outlined,
                      "Fecha",
                      _formatearFechas(),
                    ),
                    _infoFila(
                      Icons.access_time_rounded,
                      "Hora",
                      _formatearHoras(),
                    ),
                    _infoFila(
                      Icons.confirmation_number_outlined,
                      "ID de reserva",
                      '#${reserva['reserva_id'] ?? reserva['id']}',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Botones
              if (!cancelada) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colores.primary),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colores.primary, size: 18),
                        SizedBox(width: 8),
                        Text("Modificar reserva", style: TextStyle(color: Colores.primary)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.danger.withOpacity(0.15),
                      foregroundColor: Colores.text,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colores.danger),
                      ),
                    ),
                    onPressed: _cargando ? null : _confirmarCancelacion,
                    child: _cargando
                        ? CircularProgressIndicator(color: Colores.danger)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, color: Colores.danger, size: 18),
                              SizedBox(width: 8),
                              Text("Cancelar reserva", style: TextStyle(color: Colores.danger)),
                            ],
                          ),
                  ),
                ),
              ],

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
