import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'horario_disponible.dart';

class PantallaExplorarRecursos extends StatefulWidget {
  final String idUsuario;
  const PantallaExplorarRecursos({super.key, required this.idUsuario});

  @override
  State<PantallaExplorarRecursos> createState() =>
      _PantallaExplorarRecursosState();
}

class _PantallaExplorarRecursosState extends State<PantallaExplorarRecursos> {
  List<dynamic> _recursos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  Future<void> _fetchRecursos() async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _recursos = jsonDecode(response.body);
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF111417), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Explorar Recursos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'Selecciona un recurso para reservar',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
              Expanded(
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4AA3FF),
                        ),
                      )
                    : _recursos.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay recursos disponibles',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchRecursos,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _recursos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final r = _recursos[index];
                              return GestureDetector(
  onTap: () async {

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id_usuario');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaHorario(
          recursoId: r['id'],
          idUsuario: userId ?? '',
        ),
      ),
    );

  },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2026),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF232B33),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4AA3FF)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.sports_soccer_outlined,
                                        color: Color(0xFF4AA3FF),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r['name'] ?? r['nombre'] ?? 'Recurso',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (r['description'] !=
                                                  null ||
                                              r['descripcion'] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                r['description'] ??
                                                    r['descripcion'] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF4AA3FF),
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
      ),
    );
  }
}