import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'CreateReservas.dart';
import 'horario_disponible.dart';
import 'AdminPanel.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MisReservas.dart';
import 'Perfil.dart';
import '../services/notificacion_services.dart';
import '../screens/Notificaciones.dart';
import 'ExplorarRecursos.dart';
import 'AdminUsuarios.dart';


class PantallaHome extends StatefulWidget {
  final String idUsuario;
  const PantallaHome({super.key, required this.idUsuario});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  int _currentIndex = 0;
  String _idUsuario = '';
  int _roleId = 0;
  List<Map<String, dynamic>> _categories = [];

  final GlobalKey<PantallaExplorarRecursosState> _explorarKey = GlobalKey();
  final GlobalKey<PantallaMisReservasState>       _misReservasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _idUsuario = widget.idUsuario;
    _loadRole();
    fetchCategories();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _roleId = prefs.getInt('role_id') ?? 0;
      });
    }

    try {
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        final response = await http.get(
          Uri.parse("${AppConfig.baseUrl}/auth/me/"),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final int backendRoleId = data['role_id'] ?? 0;
          await prefs.setInt('role_id', backendRoleId);
          if (mounted && backendRoleId != _roleId) {
            setState(() {
              _roleId = backendRoleId;
            });
          }
        }
      }
    } catch (_) {}
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'meeting_room':
        return Icons.meeting_room_rounded;
      case 'theater_comedy':
        return Icons.theater_comedy_rounded;
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'science':
        return Icons.science_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Future<void> _refreshAllData() async {
    await fetchCategories();
    if (_explorarKey.currentState != null) {
      await _explorarKey.currentState!.fetchCategories();
      await _explorarKey.currentState!.fetchRecursos();
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/categorias/list/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categories = data.asMap().entries.map((e) {
              final i    = e.key;
              final item = e.value;
              return {
                'id':    item['id'],
                'label': item['nombre'],
                'desc':  item['descripcion'] ?? '',
                'icon':  _getIconData(item['icono']),
                'color': Colores.catColors[i % Colores.catColors.length],
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  List<Widget> get _pages => [
    _HomeTab(
      categories: _categories,
      idUsuario: _idUsuario,
      roleId: _roleId,
      onRefresh: _refreshAllData,
      onCategorySelected: (catId) {
        setState(() => _currentIndex = 1);
        _explorarKey.currentState?.filtrarPorCategoria(catId);
      },
    ),
    PantallaExplorarRecursos(key: _explorarKey, idUsuario: _idUsuario),
    PantallaMisReservas(key: _misReservasKey),
    PantallaPerfil(),
  ];

  void _openCreateReserva() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaCreateReserva()),
    );
    if (result == true) {
      _explorarKey.currentState?.fetchRecursos();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.background,
      floatingActionButton: _currentIndex == 0 && _roleId == 1
          ? FloatingActionButton(
              elevation: 8,
              backgroundColor: Colores.primaryDark,
              onPressed: _openCreateReserva,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colores.surface,
        border: Border(top: BorderSide(color: Colores.border, width: 0.8)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 2) _misReservasKey.currentState?.fetchMisReservas();
        },
        type:                  BottomNavigationBarType.fixed,
        backgroundColor:       Colors.transparent,
        elevation:             0,
        selectedItemColor:     Colores.primary,
        unselectedItemColor:   Colores.textSecondary,
        selectedFontSize:      11,
        unselectedFontSize:    11,
        iconSize:              24,
        showSelectedLabels:    true,
        showUnselectedLabels:  true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded),              label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined),          label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined),   label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),            label: 'Perfil'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String idUsuario;
  final Function(int?) onCategorySelected;
  final int roleId;
  final VoidCallback onRefresh;

  const _HomeTab({
    required this.categories,
    required this.idUsuario,
    required this.onCategorySelected,
    required this.roleId,
    required this.onRefresh,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Map<String, dynamic>> _recursos = [];
  bool _cargando = true;

  // Búsqueda
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _resultadosBusqueda = [];
  bool _buscando = false;

  // Filtro de categoría activo en el home
  int? _catSeleccionada;   // null = todas

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Datos ────────────────────────────────────────────────────────────────

  Future<void> _fetchRecursos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final res   = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _recursos = data.map((r) => Map<String, dynamic>.from(r as Map)).toList();
            _cargando = false;
          });
        }
      } else {
        if (mounted) setState(() => _cargando = false);
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }



  List<Map<String, dynamic>> get _recursosFiltrados {
    if (_catSeleccionada == null) return _recursos;
    return _recursos.where((r) {
      // El recurso puede traer categoria_id o categoria como mapa
      final catId = r['categoria_id'] ?? r['categoria']?['id'];
      return catId == _catSeleccionada;
    }).toList();
  }

  List<Map<String, dynamic>> get _disponibles =>
      _recursosFiltrados.where((r) => r['es_visible'] == true).toList();

  void _onSearch(String texto) {
    if (texto.isEmpty) {
      setState(() { _resultadosBusqueda = []; _buscando = false; });
      return;
    }
    final q = texto.toLowerCase();
    setState(() {
      _buscando = true;
      _resultadosBusqueda = _recursos.where((r) {
        final nombre   = (r['name'] ?? r['nombre'] ?? '').toString().toLowerCase();
        final desc     = (r['description'] ?? r['descripcion'] ?? '').toString().toLowerCase();
        // También busca por nombre de categoría
        final catNombre = (r['categoria']?['nombre'] ?? '').toString().toLowerCase();
        return nombre.contains(q) || desc.contains(q) || catNombre.contains(q);
      }).toList();
    });
  }

  void _seleccionarCategoria(int? catId) {
    setState(() => _catSeleccionada = (_catSeleccionada == catId) ? null : catId);
  }

  String _getNombreCategoria(int? catId) {
    if (catId == null) return '';
    final cat = widget.categories.firstWhere(
      (c) => c['id'] == catId,
      orElse: () => {},
    );
    return cat['label'] ?? '';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo degradado sutil
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [Colores.background, Color.fromRGBO(18, 22, 30, 1)],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildGreeting(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 22),
              _buildCategoriesSection(),
              const SizedBox(height: 22),
              _buildFeaturedSection(),
              const SizedBox(height: 22),
              _buildAvailableSection(),
              const SizedBox(height: 22),
              _buildWeekCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ── Secciones ────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Hola, ¿qué tal! ',
              style: TextStyle(
                color: Colores.text,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '¿Qué te gustaría reservar hoy?',
          style: TextStyle(
            color: Colores.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Categorías',
          actionText: _catSeleccionada != null ? 'Ver todas' : '',
          onTap: _catSeleccionada != null
              ? () => setState(() => _catSeleccionada = null)
              : null,
        ),
        const SizedBox(height: 12),
        widget.categories.isEmpty
            ? _buildCategorySkeleton()
            : SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final cat       = widget.categories[i];
                    final isActive  = _catSeleccionada == cat['id'];
                    return _CategoryChip(
                      label:    cat['label'] as String,
                      icon:     cat['icon']  as IconData,
                      color:    cat['color'] as Color,
                      isActive: isActive,
                      onTap:    () => _seleccionarCategoria(cat['id'] as int),
                    );
                  },
                ),
              ),
        // Indicador de filtro activo
        if (_catSeleccionada != null) ...[
          const SizedBox(height: 10),
          _ActiveFilterBadge(
            label: _getNombreCategoria(_catSeleccionada),
            onClear: () => setState(() => _catSeleccionada = null),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedSection() {
    final lista = _recursosFiltrados;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Instalaciones destacadas'),
        const SizedBox(height: 12),
        _cargando
            ? _buildCardSkeleton(height: 190)
            : lista.isEmpty
                ? _buildEmptyState('Sin recursos en esta categoría')
                : SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) {
                        final r = lista[i];
                        return _FeaturedCard(
                          width:     270,
                          imageUrl:  r['foto_principal'] ?? '',
                          isVisible: r['es_visible'] == true,
                          title:     r['name'] ?? r['nombre'] ?? 'Recurso',
                          subtitle:  r['description'] ?? r['descripcion'] ?? '',
                          recursoId: r['id'] as int,
                          idUsuario: widget.idUsuario,
                          categoria: r['categoria']?['nombre'],
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildAvailableSection() {
    final lista = _disponibles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Disponible ahora',
              style: TextStyle(color: Colores.text, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colores.success, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _cargando
            ? _buildCardSkeleton(height: 240)
            : lista.isEmpty
                ? _buildEmptyState('No hay recursos disponibles')
                : SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) {
                        final r = lista[i];
                        return _AvailableCard(
                          width:     175,
                          imageUrl:  r['foto_principal'] ?? '',
                          title:     r['name'] ?? r['nombre'] ?? 'Recurso',
                          capacity:  r['capacidad'] ?? 0,
                          categoria: r['categoria']?['nombre'],
                          recursoId: r['id'] as int,
                          idUsuario: widget.idUsuario,
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return FutureBuilder<int>(
      future: SharedPreferences.getInstance().then((p) => p.getInt('role_id') ?? 0),
      builder: (_, snap) {
        final isAdmin = (snap.data ?? 0) == 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colores.categoryGlow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colores.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colores.primary, size: 18),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ResiBook',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            // Acciones
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAdmin)
                  _IconBtn(
                    icon: Icons.admin_panel_settings_outlined,
                    color: Colores.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaAdminUsuarios()),
                    ),
                  ),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                  stream: widget.idUsuario.isEmpty
                      ? const Stream.empty()
                      : NotificacionService().contarNoLeidas(widget.idUsuario),
                  builder: (_, snap) {
                    final count = snap.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count', style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colores.danger,
                      child: _IconBtn(
                        icon: Icons.notifications_outlined,
                        color: Colores.icon,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificacionesScreen(idUsuario: widget.idUsuario),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colores.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _buscando ? Colores.primary.withOpacity(0.5) : Colores.border,
            ),
            boxShadow: _buscando
                ? [BoxShadow(color: Colores.primary.withOpacity(0.08), blurRadius: 12)]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: _buscando ? Colores.primary : Colores.icon,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colores.text, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Buscar recursos o categorías...',
                    hintStyle: TextStyle(color: Colores.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_buscando)
                GestureDetector(
                  onTap: () { _searchController.clear(); _onSearch(''); },
                  child: const Icon(Icons.close_rounded, color: Colores.icon, size: 18),
                ),
            ],
          ),
        ),
        // Dropdown resultados
        if (_buscando)
          _SearchResults(
            resultados:  _resultadosBusqueda,
            idUsuario:   widget.idUsuario,
            categories:  widget.categories,
            onCatTap:    (catId) {
              _searchController.clear();
              _onSearch('');
              _seleccionarCategoria(catId);
            },
            onRecursoTap: () { _searchController.clear(); _onSearch(''); },
          ),
      ],
    );
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────

  Widget _buildCategorySkeleton() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => _Shimmer(width: 64, height: 96, radius: 16),
      ),
    );
  }

  Widget _buildCardSkeleton({required double height}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => _Shimmer(width: 220, height: height, radius: 18),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, color: Colores.textMuted, size: 32),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(color: Colores.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

Widget _buildWeekCard() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PantallaMisReservas(),
        ),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colores.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colores.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colores.categoryGlow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colores.primary.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colores.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MIS RESERVAS',
                  style: TextStyle(
                    color: Colores.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Ver tus reservas',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Consulta tus reservas activas y pendientes',
                  style: TextStyle(
                    color: Colores.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right_rounded,
            color: Colores.primary,
            size: 24,
          ),
        ],
      ),
    ),
  );
}
}




class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.actionText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colores.text, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        if (actionText != null && actionText!.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: const TextStyle(color: Colores.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, color: Colores.primary, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _ActiveFilterBadge({required this.label, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(124, 111, 247, 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colores.primary.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.filter_list_rounded, color: Colores.primary, size: 13),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(color: Colores.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close_rounded, color: Colores.primary, size: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _CategoryChip extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final Color     color;
  final bool      isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive ? color : color.withOpacity(0.25),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))]
                    : null,
              ),
              child: Icon(icon, color: isActive ? Colors.white : color, size: 26),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colores.text : Colores.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _gradientPlaceholder(String name, {double fontSize = 28}) {
  final inicial = name.isNotEmpty ? name[0].toUpperCase() : '?';
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
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}


class _SearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> resultados;
  final List<Map<String, dynamic>> categories;
  final String idUsuario;
  final Function(int) onCatTap;
  final VoidCallback onRecursoTap;

  const _SearchResults({
    required this.resultados,
    required this.categories,
    required this.idUsuario,
    required this.onCatTap,
    required this.onRecursoTap,
  });

  @override
  Widget build(BuildContext context) {
    // Categorías que coinciden con la búsqueda (no mostrar de nuevo si ya están en recursos)
    final query = ''; // se filtra externamente; aquí sólo mostramos lo recibido

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colores.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: resultados.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, color: Colores.textMuted, size: 20),
                  SizedBox(width: 8),
                  Text('Sin resultados', style: TextStyle(color: Colores.textMuted, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resultados.length,
              separatorBuilder: (_, __) => const Divider(color: Colores.border, height: 1),
              itemBuilder: (_, i) {
                final r      = resultados[i];
                final imagen = r['foto_principal'];
                final catNom = r['categoria']?['nombre'];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imagen != null && imagen.isNotEmpty
                        ? Image.network(imagen, width: 44, height: 44, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(width: 44, height: 44, color: Colores.border,
                                    child: const Icon(Icons.image_outlined, color: Colores.textSecondary, size: 20)))
                        : Container(width: 44, height: 44, color: Colores.border,
                            child: const Icon(Icons.image_outlined, color: Colores.textSecondary, size: 20)),
                  ),
                  title: Text(
                    r['name'] ?? r['nombre'] ?? 'Recurso',
                    style: const TextStyle(color: Colores.text, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: catNom != null
                      ? Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(124, 111, 247, 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(catNom,
                                style: const TextStyle(color: Colores.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ])
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colores.textMuted, size: 13),
                  onTap: () async {
                    onRecursoTap();
                    final prefs  = await SharedPreferences.getInstance();
                    final userId = prefs.getString('id_usuario');
                    if (!context.mounted) return;
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PantallaHorario(
                        recursoId: r['id'] as int,
                        idUsuario: userId ?? idUsuario,
                      ),
                    ));
                  },
                );
              },
            ),
    );
  }
}


class _FeaturedCard extends StatelessWidget {
  final double  width;
  final String  imageUrl;
  final bool    isVisible;
  final String  title;
  final String  subtitle;
  final int     recursoId;
  final String  idUsuario;
  final String? categoria;

  const _FeaturedCard({
    required this.width,
    required this.imageUrl,
    required this.isVisible,
    required this.title,
    required this.subtitle,
    required this.recursoId,
    required this.idUsuario,
    this.categoria,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs  = await SharedPreferences.getInstance();
        final userId = prefs.getString('id_usuario');
        if (!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PantallaHorario(recursoId: recursoId, idUsuario: userId ?? idUsuario),
        ));
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colores.surfaceAlt,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _NoImage())
                  : _NoImage(),
              // Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                    colors: [Colors.transparent, Colores.cardOverlay],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),
              // Tag disponibilidad
              Positioned(
                top: 12, left: 12,
                child: _StatusTag(isVisible: isVisible),
              ),
              // Categoría tag
              if (categoria != null)
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(124, 111, 247, 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(categoria!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              // Info inferior
              Positioned(
                left: 14, right: 14, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _AvailableCard extends StatelessWidget {
  final double  width;
  final String  imageUrl;
  final String  title;
  final int     capacity;
  final String? categoria;
  final int     recursoId;
  final String  idUsuario;

  const _AvailableCard({
    required this.width,
    required this.imageUrl,
    required this.title,
    required this.capacity,
    this.categoria,
    required this.recursoId,
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs  = await SharedPreferences.getInstance();
        final userId = prefs.getString('id_usuario');
        if (!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => PantallaHorario(recursoId: recursoId, idUsuario: userId ?? idUsuario),
        ));
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colores.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colores.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              SizedBox(
                height: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _NoImage())
                        : _NoImage(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end:   Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colores.tagAvailable,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colores.success.withOpacity(0.4)),
                        ),
                        child: const Text('LIBRE',
                            style: TextStyle(color: Colores.success, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoria != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          categoria!.toUpperCase(),
                          style: const TextStyle(
                            color: Colores.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colores.text, fontSize: 14, fontWeight: FontWeight.w800, height: 1.2)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.people_outline_rounded, color: Colores.textSecondary, size: 13),
                        const SizedBox(width: 4),
                        Text('$capacity personas',
                            style: const TextStyle(color: Colores.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _StatusTag extends StatelessWidget {
  final bool isVisible;
  const _StatusTag({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isVisible ? Colores.tagAvailable : Colores.tagUnavailable,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isVisible ? Colores.success.withOpacity(0.5) : Colores.danger.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVisible ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            color: isVisible ? Colores.success : Colores.danger,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            isVisible ? 'Disponible' : 'No disponible',
            style: TextStyle(
              color: isVisible ? Colores.success : Colores.danger,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colores.surfaceAlt,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colores.textMuted, size: 32),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colores.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colores.border),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width, height, radius;
  const _Shimmer({required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width:  widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colores.surfaceAlt.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}


class _AlertsIcon extends StatelessWidget {
  const _AlertsIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_outlined),
        Positioned(
          right: -2, top: -2,
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: Colores.danger,
              shape: BoxShape.circle,
              border: Border.all(color: Colores.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}