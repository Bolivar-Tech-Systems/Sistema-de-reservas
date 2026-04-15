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
  State<PantallaMisReservas> createState() => _PantallaMisReservasState();
}

class _PantallaMisReservasState extends State<PantallaMisReservas> {
  List<dynamic> reservas = [];
  bool _cargando = true;
  String _filtro = 'todas';

  final List<Map<String, String>> filtros = [
    {'label': 'Todas', 'value': 'todas'},
    {'label': 'Activas', 'value': 'activa'},
    {'label': 'Pendiente', 'value': 'pendiente'},
    {'label': 'Canceladas', 'value': 'cancelada'},
  ];

  @override
  void initState() {
    super.initState();
    fetchMisReservas();
  }

  Future<void> fetchMisReservas() async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/reservas/reservas_usuario/"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);

        final List<dynamic> listaCompleta = await Future.wait(
          lista.map((ruRaw) async {
            final ru = Map<String, dynamic>.from(ruRaw as Map);
            try {
              final detalle = await http.get(
                Uri.parse("${AppConfig.baseUrl}/reservas/${ru['reserva_id']}"),
                headers: {'Authorization': 'Bearer $token'},
              );
              if (detalle.statusCode == 200) {
                final info = Map<String, dynamic>.from(jsonDecode(detalle.body) as Map);
                return <String, dynamic>{
                  ...ru,
                  'name': info['name'],
                  'description': info['description'],
                };
              }
            } catch (_) {}
            return <String, dynamic>{
              ...ru,
              'name': 'Reserva #${ru['reserva_id']}',
              'description': null,
            };
          }),
        );

        setState(() {
          reservas = listaCompleta;
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar reservas: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No se pudo conectar al servidor")),
        );
      }
    }
  }

  List<dynamic> get reservasFiltradas {
    if (_filtro == 'todas') return reservas;
    return reservas
        .where((r) => (r['estado'] ?? '').toString().toLowerCase() == _filtro)
        .toList();
  }

  String _formatearFechas(dynamic reserva) {
    final inicio = reserva['fecha_inicio'];
    final fin = reserva['fecha_fin'];
    if (inicio == null && fin == null) return 'Sin fecha';
    if (inicio != null && fin != null) return '$inicio → $fin';
    return inicio ?? fin ?? 'Sin fecha';
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return Colores.primary;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colores.danger;
      default:
        return Colores.textSecondary;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return Icons.check_circle_outline;
      case 'pendiente':
        return Icons.schedule_outlined;
      case 'cancelada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
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
        padding: EdgeInsets.only(top: 25, left: 10, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),

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
                  "Mis Reservas",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colores.text,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filtros.map((f) {
                  final seleccionado = _filtro == f['value'];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filtro = f['value']!),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: seleccionado ? Colores.primaryDark : Colores.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: seleccionado ? Colores.primary : Colores.border,
                          ),
                        ),
                        child: Text(
                          f['label']!,
                          style: TextStyle(
                            color: seleccionado ? Colores.text : Colores.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 20),

            // Lista
            Expanded(
              child: _cargando
                  ? Center(child: CircularProgressIndicator(color: Colores.primary))
                  : reservasFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, color: Colores.textMuted, size: 50),
                              SizedBox(height: 12),
                              Text(
                                "No hay reservas",
                                style: TextStyle(color: Colores.textSecondary, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: Colores.primary,
                          onRefresh: fetchMisReservas,
                          child: ListView.separated(
                            itemCount: reservasFiltradas.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final reserva = reservasFiltradas[index];
                              final estado = (reserva['estado'] ?? 'pendiente')
                                  .toString()
                                  .toLowerCase();

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaDetalleReserva(
                                        reserva: reserva,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) fetchMisReservas();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colores.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colores.border),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          "assets/images/nitro.jpg",
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reserva['name'] ?? 'Reserva #${reserva['reserva_id']}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colores.text,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _formatearFechas(reserva),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colores.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            _iconoEstado(estado),
                                            color: _colorEstado(estado),
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            estado[0].toUpperCase() + estado.substring(1),
                                            style: TextStyle(
                                              color: _colorEstado(estado),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}