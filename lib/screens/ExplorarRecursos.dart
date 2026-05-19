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
  List<Map<String, dynamic>> _recursos = [];
  List<Map<String, dynamic>> _recursosFiltrados = [];
  bool _cargando = true;
  String _busqueda = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
    _searchController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recursos = data
              .map((r) => Map<String, dynamic>.from(r as Map))
              .toList();
          _recursosFiltrados = _recursos;
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _cargando = false);
    }
  }

  void _aplicarFiltros() {
    final busqueda = _searchController.text.toLowerCase();
    setState(() {
      _busqueda = busqueda;
      _recursosFiltrados = _recursos.where((r) {
        final nombre = (r['nombre'] ?? r['name'] ?? '')
            .toString()
            .toLowerCase();
        final descripcion = (r['descripcion'] ?? r['description'] ?? '')
            .toString()
            .toLowerCase();
        return nombre.contains(busqueda) || descripcion.contains(busqueda);
      }).toList();
    });
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Explorar Recursos',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'Selecciona un recurso para reservar',
                  style: TextStyle(color: Colores.textSecondary, fontSize: 14),
                ),
              ),

              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colores.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colores.text),
                    decoration: InputDecoration(
                      hintText: 'Buscar recurso...',
                      hintStyle: TextStyle(color: Colores.textSecondary),
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        color: Colores.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de recursos
              Expanded(
                child: _cargando
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colores.primary,
                        ),
                      )
                    : _recursosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              color: Colores.textMuted,
                              size: 50,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _busqueda.isEmpty
                                  ? 'No hay recursos disponibles'
                                  : 'No se encontraron resultados',
                              style: TextStyle(
                                color: Colores.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colores.primary,
                        onRefresh: _fetchRecursos,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _recursosFiltrados.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final r = _recursosFiltrados[index];
                            return _buildRecursoCard(r);
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

  Widget _buildRecursoCard(Map<String, dynamic> recurso) {
    final nombre = recurso['nombre'] ?? recurso['name'] ?? 'Recurso';
    final descripcion = recurso['descripcion'] ?? recurso['description'] ?? '';
    final capacidad = recurso['capacidad'] ?? 0;
    final esVisible = recurso['es_visible'] == true;
    final recursoId = recurso['id'] as int;
    final imagen = recurso['foto_principal'];

    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('id_usuario');

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PantallaHorario(recursoId: recursoId, idUsuario: userId ?? ''),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colores.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colores.border),
        ),
        child: Row(
          children: [
            // Imagen o icono
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imagen != null && imagen.isNotEmpty
                  ? Image.network(
                      imagen,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                    )
                  : _buildPlaceholderIcon(),
            ),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      color: Colores.text,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (descripcion.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        descripcion,
                        style: TextStyle(
                          color: Colores.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (capacidad > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 12,
                            color: Colores.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cap: $capacidad',
                            style: TextStyle(
                              color: Colores.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Estado badge + Arrow
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: esVisible
                        ? const Color(0xFF22C55E).withOpacity(0.15)
                        : Colores.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: esVisible
                          ? const Color(0xFF22C55E)
                          : Colores.danger,
                    ),
                  ),
                  child: Text(
                    esVisible ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: esVisible
                          ? const Color(0xFF22C55E)
                          : Colores.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colores.primary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colores.primaryDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colores.textSecondary,
          size: 26,
        ),
      ),
    );
  }
}
