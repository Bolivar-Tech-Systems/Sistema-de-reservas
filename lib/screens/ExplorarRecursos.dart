import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'horario_disponible.dart';
import 'GestionDisponibilidad.dart';

class PantallaExplorarRecursos extends StatefulWidget {
  final String idUsuario;
  const PantallaExplorarRecursos({super.key, required this.idUsuario});

  @override
  State<PantallaExplorarRecursos> createState() =>
      PantallaExplorarRecursosState();
}

class PantallaExplorarRecursosState extends State<PantallaExplorarRecursos> {
  List<Map<String, dynamic>> _recursos = [];
  List<Map<String, dynamic>> _recursosFiltrados = [];
  bool _cargando = true;
  String _busqueda = '';
  bool _vistaGrilla = true;
  int _roleId = 0;
  Set<int> _favoritoIds = {};

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadRole();
    fetchRecursos();
    _fetchCategories();
    _fetchFavoritos();
    _searchController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _roleId = prefs.getInt('role_id') ?? 0);
  }

  Future<void> _fetchFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/favoritos/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _favoritoIds = data.map((r) => r['id'] as int).toSet();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorito(int recursoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/favoritos/$recursoId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            if (data['favorito'] == true) {
              _favoritoIds.add(recursoId);
            } else {
              _favoritoIds.remove(recursoId);
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> fetchRecursos() async {
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
          _recursos = data.map((r) => Map<String, dynamic>.from(r as Map)).toList();
          _recursosFiltrados = _recursos;
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  int? _selectedCategoriaId;

  void filtrarPorCategoria(int? categoriaId) {
    setState(() {
      _selectedCategoriaId = categoriaId;
    });
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _busqueda = q;
      _recursosFiltrados = _recursos.where((r) {
        final n = (r['nombre'] ?? r['name'] ?? '').toString().toLowerCase();
        final d = (r['descripcion'] ?? r['description'] ?? '').toString().toLowerCase();
        final matchesQuery = n.contains(q) || d.contains(q);
        final matchesCategory = _selectedCategoriaId == null || r['categoria_id'] == _selectedCategoriaId;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _irAHorario(int recursoId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id_usuario') ?? '';
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaHorario(recursoId: recursoId, idUsuario: userId),
      ),
    );
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/categorias/list/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categories = data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          });
        }
      }
    } catch (_) {}
  }

  Widget _buildCategoryBar() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final isSelected = isAll ? (_selectedCategoriaId == null) : (_selectedCategoriaId == _categories[index - 1]['id']);
          final label = isAll ? 'Todos' : _categories[index - 1]['nombre'];
          
          return GestureDetector(
            onTap: () {
              filtrarPorCategoria(isAll ? null : _categories[index - 1]['id'] as int);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colores.primaryDark : Colores.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colores.primary : Colores.border,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colores.text : Colores.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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
              _buildHeader(),
              _buildSearchBar(),
              const SizedBox(height: 10),
              _buildCategoryBar(),
              const SizedBox(height: 10),
              _buildSubtitulo(),
              const SizedBox(height: 8),
              Expanded(child: _buildCuerpo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explorar',
                    style: TextStyle(
                      color: Colores.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    )),
              ],
            ),
          ),
          // Toggle grilla/lista
          GestureDetector(
            onTap: () => setState(() => _vistaGrilla = !_vistaGrilla),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colores.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colores.border),
              ),
              child: Icon(
                _vistaGrilla ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: Colores.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colores.border),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colores.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar recurso...',
            hintStyle: const TextStyle(color: Colores.textMuted, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Colores.icon, size: 20),
            suffixIcon: _busqueda.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colores.icon, size: 18),
                    onPressed: _searchController.clear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitulo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _cargando
            ? 'Cargando...'
            : '${_recursosFiltrados.length} recurso${_recursosFiltrados.length != 1 ? 's' : ''} disponible${_recursosFiltrados.length != 1 ? 's' : ''}',
        style: const TextStyle(color: Colores.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _buildCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colores.primary));
    }
    if (_recursosFiltrados.isEmpty) {
      return Center(
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
              child: const Icon(Icons.search_off_rounded, color: Colores.textMuted, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              _busqueda.isEmpty ? 'Sin recursos disponibles' : 'Sin resultados para "$_busqueda"',
              style: const TextStyle(color: Colores.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colores.primary,
      backgroundColor: Colores.surfaceAlt,
      onRefresh: fetchRecursos,
      child: _vistaGrilla ? _buildGrilla() : _buildLista(),
    );
  }

  // ── Vista grilla 2 columnas ────────────────────────────────────────
  Widget _buildGrilla() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _recursosFiltrados.length,
      itemBuilder: (_, i) => _buildCardGrilla(_recursosFiltrados[i]),
    );
  }

  Widget _buildCardGrilla(Map<String, dynamic> r) {
    final nombre    = r['nombre'] ?? r['name'] ?? 'Recurso';
    final foto      = r['foto_principal'];
    final esVisible = r['es_visible'] == true;
    final precio    = r['precio_por_hora'];
    final rating    = r['calificacion_promedio'];
    final recursoId = r['id'] as int;

    return GestureDetector(
      onTap: () => _irAHorario(recursoId),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colores.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    foto != null && foto.toString().isNotEmpty
                        ? Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _gradientPlaceholder(nombre),
                          )
                        : _gradientPlaceholder(nombre),
                    // Overlay precio
                    if (precio != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${(precio as num).toStringAsFixed(0)}/h',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    // Badge disponible/ocupado
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: esVisible ? Colores.success : Colores.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (esVisible ? Colores.success : Colores.danger)
                                  .withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón favorito
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorito(recursoId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _favoritoIds.contains(recursoId)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _favoritoIds.contains(recursoId)
                                ? Colores.danger
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                          color: Colores.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      esVisible ? 'Disponible' : 'Ocupado',
                      style: TextStyle(
                        color: esVisible ? Colores.success : Colores.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (rating != null && (rating as num) > 0)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.orange, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            (rating as num).toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colores.textSecondary, fontSize: 11),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(Icons.arrow_forward_rounded,
                              color: Colores.primary.withOpacity(0.7), size: 13),
                          const SizedBox(width: 4),
                          const Text('Ver horarios',
                              style: TextStyle(
                                  color: Colores.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vista lista ────────────────────────────────────────────────────
  Widget _buildLista() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      itemCount: _recursosFiltrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildCardLista(_recursosFiltrados[i]),
    );
  }

  Widget _buildCardLista(Map<String, dynamic> r) {
    final nombre    = r['nombre'] ?? r['name'] ?? 'Recurso';
    final descripcion = (r['descripcion'] ?? r['description'] ?? '').toString();
    final foto      = r['foto_principal'];
    final esVisible = r['es_visible'] == true;
    final precio    = r['precio_por_hora'];
    final rating    = r['calificacion_promedio'];
    final capacidad = r['capacidad'] ?? 0;
    final recursoId = r['id'] as int;

    return GestureDetector(
      onTap: () => _irAHorario(recursoId),
      child: Container(
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colores.border),
        ),
        child: Row(
          children: [
            // Imagen izquierda
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 80,
                height: 80,
                child: foto != null && foto.toString().isNotEmpty
                    ? Image.network(foto, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _gradientPlaceholder(nombre))
                    : _gradientPlaceholder(nombre),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: const TextStyle(
                            color: Colores.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(descripcion,
                          style: const TextStyle(
                              color: Colores.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (capacidad > 0) ...[
                          const Icon(Icons.people_outline_rounded,
                              size: 11, color: Colores.icon),
                          const SizedBox(width: 3),
                          Text('$capacidad',
                              style: const TextStyle(
                                  color: Colores.textSecondary, fontSize: 11)),
                          const SizedBox(width: 10),
                        ],
                        if (precio != null) ...[
                          const Icon(Icons.attach_money_rounded,
                              size: 11, color: Colores.primary),
                          Text('${(precio as num).toStringAsFixed(0)}/h',
                              style: const TextStyle(
                                  color: Colores.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                        ],
                        if (rating != null && (rating as num) > 0) ...[
                          const Icon(Icons.star_rounded,
                              size: 11, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text((rating as num).toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colores.textSecondary, fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Badge + chevron
            Container(
              width: 75,
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: esVisible
                          ? Colores.success.withOpacity(0.12)
                          : Colores.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: esVisible
                            ? Colores.success.withOpacity(0.4)
                            : Colores.danger.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      esVisible ? 'Libre' : 'Ocupado',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: esVisible ? Colores.success : Colores.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_roleId == 1) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaGestionDisponibilidad(
                              recursoId: recursoId,
                              recursoNombre: nombre,
                            ),
                          ),
                        ).then((_) => fetchRecursos());
                      },
                      child: const Icon(Icons.settings_rounded,
                          color: Colores.primary, size: 18),
                    ),
                    const SizedBox(height: 4),
                  ],
                  GestureDetector(
                    onTap: () => _toggleFavorito(recursoId),
                    child: Icon(
                      _favoritoIds.contains(recursoId)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _favoritoIds.contains(recursoId)
                          ? Colores.danger
                          : Colores.textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colores.textMuted, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder con gradiente usando letra inicial del nombre
  Widget _gradientPlaceholder(String nombre) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colores.primaryDark.withOpacity(0.6),
            Colores.primary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Text(
          inicial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
