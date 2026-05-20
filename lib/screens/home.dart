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
import '../models/notificacion_model.dart';
import 'ExplorarRecursos.dart';

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
  final GlobalKey<PantallaMisReservasState> _misReservasKey = GlobalKey();

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
        setState(() {
          _categories = List<Map<String, dynamic>>.from(
            data.map(
              (item) => {
                'id': item['id'],
                'label': item['nombre'],
                'icon': _getIconData(item['icono']),
                'color': Colores.primary,
              },
            ),
          );
        });
      }
    } catch (_) {}
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      label: 'Explorar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: 'Reservas',
    ),
    BottomNavigationBarItem(icon: _AlertsIcon(), label: 'Alertas'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
  ];

  List<Widget> get _pages => [
    _HomeTab(
      categories: _categories,
      idUsuario: _idUsuario,
      roleId: _roleId,
      onRefresh: _refreshAllData,
      onCategorySelected: (catId) {
        setState(() {
          _currentIndex = 1;
        });
        _explorarKey.currentState?.filtrarPorCategoria(catId);
      },
      onGoToReservas: () {
        setState(() {
          _currentIndex = 2;
        });
        _misReservasKey.currentState?.fetchMisReservas();
      },
      onGoToAlertas: () {
        setState(() {
          _currentIndex = 3;
        });
      },
    ),

    PantallaExplorarRecursos(key: _explorarKey, idUsuario: _idUsuario),

    PantallaMisReservas(key: _misReservasKey),
    NotificacionesScreen(idUsuario: _idUsuario),
    PantallaPerfil(),
  ];

  void _openCreateReserva() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaCreateReserva()),
    );

    if (result == true) {
      _explorarKey.currentState?.fetchRecursos();
      // Refresca el home también
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111417),
      floatingActionButton: _currentIndex == 0 && _roleId == 1
          ? FloatingActionButton(
              elevation: 8,
              backgroundColor: Colores.background,
              onPressed: _openCreateReserva,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            _misReservasKey.currentState?.fetchMisReservas();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colores.surface,
        elevation: 0,
        selectedItemColor: Colores.primary,
        unselectedItemColor: Colores.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        iconSize: 26,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: _navItems,
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String idUsuario;
  final Function(int?) onCategorySelected;
  final int roleId;
  final VoidCallback onRefresh;
  final VoidCallback onGoToReservas;
  final VoidCallback onGoToAlertas;

  const _HomeTab({
    required this.categories,
    required this.idUsuario,
    required this.onCategorySelected,
    required this.roleId,
    required this.onRefresh,
    required this.onGoToReservas,
    required this.onGoToAlertas,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Map<String, dynamic>> _recursos = [];
  bool _cargando = true;

  List<Map<String, dynamic>> _misReservas = [];
  bool _cargandoReservas = true;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _resultadosBusqueda = [];
  bool _buscando = false;

  // ── Typewriter greeting ──
  String _displayText = '';
  String _userName = '';
  bool _typingDone = false;

  static const _phase1 = 'Hola, ¿qué tal?';

  static const _charDelay = Duration(milliseconds: 60);
  static const _eraseDelay = Duration(milliseconds: 35);
  static const _pauseDelay = Duration(milliseconds: 700);

  Future<void> _runTypewriter() async {
    // 1. Cargar nombre del usuario
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('user_name') ?? '';
    if (mounted) setState(() => _userName = nombre);

    // Determine greeting phase2
    final phase2 = nombre.isNotEmpty ? 'Hola, $nombre' : 'Hola, ¿qué tal?';

    // 2. Escribir fase 1
    for (int i = 0; i <= _phase1.length; i++) {
      if (!mounted) return;
      setState(() => _displayText = _phase1.substring(0, i));
      await Future.delayed(_charDelay);
    }

    // 3. Pausa
    await Future.delayed(_pauseDelay);

    // 4. Borrar
    for (int i = _phase1.length; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _displayText = _phase1.substring(0, i));
      await Future.delayed(_eraseDelay);
    }

    // 5. Pausa breve
    await Future.delayed(const Duration(milliseconds: 300));

    // 6. Escribir fase 2 (nombre real) y quedar fijo
    for (int i = 0; i <= phase2.length; i++) {
      if (!mounted) return;
      setState(() => _displayText = phase2.substring(0, i));
      await Future.delayed(_charDelay);
    }

    if (mounted) setState(() => _typingDone = true);
  }
  // ─────────────────────────

  void _onSearch(String texto) {
    if (texto.isEmpty) {
      setState(() {
        _resultadosBusqueda = [];
        _buscando = false;
      });
      return;
    }
    setState(() {
      _buscando = true;
      _resultadosBusqueda = _recursos.where((r) {
        final nombre = (r['name'] ?? r['nombre'] ?? '')
            .toString()
            .toLowerCase();
        return nombre.contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRecursos();
    _fetchReservas();
    _runTypewriter();
  }

  Future<void> _fetchRecursos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/list/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _recursos = data
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
            _cargando = false;
          });
        }
      } else {
        if (mounted) setState(() => _cargando = false);
      }
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _fetchReservas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/reservas/reservas_usuario/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _misReservas = data.map((r) => Map<String, dynamic>.from(r as Map)).toList();
            _cargandoReservas = false;
          });
        }
      } else {
        if (mounted) setState(() => _cargandoReservas = false);
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoReservas = false);
    }
  }

  List<Map<String, dynamic>> get _disponibles =>
      _recursos.where((r) => r['es_visible'] == true).toList();

  // Filtro por próximas horas - comentado hasta tener horarios en BD
  // List<Map<String, dynamic>> get _proximosEnHoras {
  //   final ahora = DateTime.now();
  //   final limite = ahora.add(const Duration(hours: 3));
  //   return _disponibles.where((r) {
  //     // final horaInicio = r['hora_inicio'];
  //     // final partes = horaInicio.split(':');
  //     // final hora = DateTime(ahora.year, ahora.month, ahora.day,
  //     //     int.parse(partes[0]), int.parse(partes[1]));
  //     // return hora.isAfter(ahora) && hora.isBefore(limite);
  //     return true;
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colores.background, Colores.surface, Colores.background],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    _displayText,
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  // Cursor parpadeante mientras anima
                  if (!_typingDone)
                    _BlinkingCursor(),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Que te gustaria reservar el dia de hoy?',
                style: TextStyle(
                  color: Colores.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildSectionHeader(
                title: 'Categorías',
                actionText: 'Ver todo',
                onTap: () => widget.onCategorySelected(null),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = widget.categories[index];
                    return _CategoryItem(
                      label: item['label'] as String,
                      icon: item['icon'] as IconData,
                      color: item['color'] as Color,
                      onTap: () {
                        widget.onCategorySelected(item['id'] as int?);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Instalaciones destacadas',
                style: TextStyle(
                  color:Colores.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: (Colores.primary)
                      ),
                    )
                  : SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recursos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final r = _recursos[index];
                          return _FeaturedCard(
                            width: 270,
                            imageUrl: r['foto_principal'] ?? '',
                            tag: r['es_visible'] == true
                                ? 'Disponible'
                                : 'No disponible',
                            title: r['name'] ?? r['nombre'] ?? 'Recurso',
                            subtitle:
                                r['description'] ?? r['descripcion'] ?? '',
                            recursoId: r['id'] as int,
                            idUsuario: widget.idUsuario,
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onGoToReservas,
                        child: const Text(
                          'Disponible ahora',
                          style: TextStyle(
                            color: Colores.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.circle, size: 8, color: Colores.primary),
                    ],
                  ),
                  // Filtro por horas - comentado hasta tener horarios en BD
                  // Text(
                  //   'Filter',
                  //   style: TextStyle(
                  //     color: Color(0xFF94A3B8),
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              _cargando
                  ? const SizedBox()
                  : SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _disponibles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final r = _disponibles[index];
                           return _AvailableCard(
                             width: 175,
                             imageUrl: r['foto_principal'] ?? '',
                             label: 'RECURSO',
                             title: r['name'] ?? r['nombre'] ?? 'Recurso',
                             capacity: 'Capacidad: ${r['capacidad'] ?? 0} personas',
                             status: 'DISPONIBLE',
                             statusColor: const Color(0xFF22C55E),
                             recursoId: r['id'] as int,
                             idUsuario: widget.idUsuario,
                           );
                        },
                      ),
                    ),
              const SizedBox(height: 18),
              _buildWeekCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final isAdmin = widget.roleId == 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colores.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flash_on_rounded,
            color: Colores.icon,
            size: 18,
          ),
        ),
        const Text(
          'ResiBook',
          style: TextStyle(
            color: Colores.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined, color: Colores.primary),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantallaAdminPanel()),
                  );
                  widget.onRefresh();
                  _fetchRecursos();
                },
                tooltip: 'Panel administrativo',
              ),
            PopupMenuButton<void>(
              offset: const Offset(0, 42),
              color: Colores.surfaceAlt,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colores.border),
              ),
              child: StreamBuilder<int>(
                stream: widget.idUsuario.isEmpty
                    ? const Stream.empty()
                    : NotificacionService().contarNoLeidas(widget.idUsuario),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.notifications, color: Colores.icon, size: 24),
                    ),
                  );
                },
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<void>(
                    enabled: false,
                    child: Container(
                      width: 290,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Notificaciones',
                                style: TextStyle(
                                  color: Colores.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (widget.idUsuario.isNotEmpty)
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await NotificacionService().marcarTodasLeidas(widget.idUsuario);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Leer todas',
                                    style: TextStyle(
                                      color: Colores.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(color: Colores.border, height: 16),
                          StreamBuilder<List<Notificacion>>(
                            stream: NotificacionService().getNotificaciones(widget.idUsuario),
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colores.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final list = snap.data ?? [];
                              if (list.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'No tienes notificaciones',
                                      style: TextStyle(
                                        color: Colores.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final limitList = list.take(4).toList();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: limitList.map((notif) {
                                  return InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await NotificacionService().marcarLeida(notif.id);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            margin: const EdgeInsets.only(top: 5, right: 8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: notif.leida ? Colors.transparent : Colores.primary,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notif.titulo,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colores.text,
                                                    fontSize: 12.5,
                                                    fontWeight: notif.leida ? FontWeight.normal : FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  notif.mensaje,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colores.textSecondary,
                                                    fontSize: 11,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const Divider(color: Colores.border, height: 16),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              widget.onGoToAlertas();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Mostrar todas',
                                    style: TextStyle(
                                      color: Colores.primary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colores.primary,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colores.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colores.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colores.icon, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colores.text, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Buscar recursos...',
                    hintStyle: TextStyle(
                      color: Colores.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_buscando)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colores.icon,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        if (_buscando && _resultadosBusqueda.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colores.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colores.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _resultadosBusqueda.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colores.border, height: 1),
              itemBuilder: (context, index) {
                final r = _resultadosBusqueda[index];
                final imagen = r['foto_principal'];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imagen != null && imagen.isNotEmpty
                        ? Image.network(
                            imagen,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              color: Colores.icon,
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            color: Colores.icon,
                          ),
                  ),
                  title: Text(
                    r['nombre'] ?? 'Recurso',
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    r['descripcion'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colores.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colores.primaryDark,
                  ),
                  onTap: () async {
                    _searchController.clear();
                    _onSearch('');
                    final prefs = await SharedPreferences.getInstance();
                    final userId = prefs.getString('id_usuario');
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaHorario(
                          recursoId: r['id'] as int,
                          idUsuario: userId ?? widget.idUsuario,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        if (_buscando && _resultadosBusqueda.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colores.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colores.border),
            ),
            child: const Center(
              child: Text(
                'No se encontraron recursos',
                style: TextStyle(color: Colores.textSecondary, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colores.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  color: Colores.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                color: Colores.icon,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    if (_cargandoReservas) {
      return Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colores.border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colores.primary, strokeWidth: 2),
        ),
      );
    }

    final activas = _misReservas.where((r) {
      final e = (r['estado'] ?? '').toString().toLowerCase();
      return e == 'pendiente' || e == 'confirmada' || e == 'activa';
    }).toList();
    
    // Find the next upcoming reservation
    Map<String, dynamic>? proxima;
    DateTime? proximaFecha;

    final ahora = DateTime.now();

    for (var r in activas) {
      try {
        final fechaStr = r['fecha_inicio'] ?? r['fecha_reserva'];
        final horaStr = r['hora_inicio'];
        if (fechaStr != null && horaStr != null) {
          final partesFecha = fechaStr.split('-');
          final partesHora = horaStr.split(':');
          final dt = DateTime(
            int.parse(partesFecha[0]),
            int.parse(partesFecha[1]),
            int.parse(partesFecha[2]),
            int.parse(partesHora[0]),
            int.parse(partesHora[1]),
          );

          if (dt.isAfter(ahora)) {
            if (proximaFecha == null || dt.isBefore(proximaFecha)) {
              proximaFecha = dt;
              proxima = r;
            }
          }
        }
      } catch (_) {}
    }

    String titulo = activas.length == 1 ? '1 Reserva activa' : '${activas.length} Reservas activas';
    String subtitulo = 'No tienes reservas próximas';
    
    if (proxima != null && proximaFecha != null) {
      final nombreRecurso = proxima['recurso'] != null ? proxima['recurso']['nombre'] : 'Recurso';
      
      String dia = '';
      if (proximaFecha.day == ahora.day && proximaFecha.month == ahora.month && proximaFecha.year == ahora.year) {
        dia = 'hoy';
      } else if (proximaFecha.day == ahora.add(const Duration(days: 1)).day && proximaFecha.month == ahora.add(const Duration(days: 1)).month && proximaFecha.year == ahora.add(const Duration(days: 1)).year) {
        dia = 'mañana';
      } else {
        dia = '${proximaFecha.day}/${proximaFecha.month}';
      }

      int hora = proximaFecha.hour;
      int min = proximaFecha.minute;
      String ampm = hora >= 12 ? 'PM' : 'AM';
      if (hora > 12) hora -= 12;
      if (hora == 0) hora = 12;
      String minStr = min < 10 ? '0$min' : '$min';

      subtitulo = 'Siguiente: $nombreRecurso $dia a las $hora:$minStr $ampm';
    }

    return GestureDetector(
      onTap: widget.onGoToReservas,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colores.border,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colores.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Colores.icon,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TU SEMANA',
                    style: TextStyle(
                      color: Color(0xFF7FC8FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: Colores.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF7FC8FF),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colores.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

class _FeaturedCard extends StatelessWidget {
  final double width;
  final String imageUrl;
  final String tag;
  final String title;
  final String subtitle;
  final int recursoId;
  final String idUsuario;

  const _FeaturedCard({
    required this.width,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.recursoId,
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('id_usuario');
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaHorario(
              recursoId: recursoId,
              idUsuario: userId ?? idUsuario,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colores.border,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradientPlaceholder(title),
                    )
                  : _gradientPlaceholder(title),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.transparent,
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5DA9FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colores.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colores.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colores.text,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
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

class _AvailableCard extends StatelessWidget {
  final double width;
  final String imageUrl;
  final String label;
  final String title;
  final String capacity;
  final String status;
  final Color statusColor;
  final int recursoId;
  final String idUsuario;

  const _AvailableCard({
    required this.width,
    required this.imageUrl,
    required this.label,
    required this.title,
    required this.capacity,
    required this.status,
    required this.statusColor,
    required this.recursoId,
    required this.idUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('id_usuario');
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaHorario(
              recursoId: recursoId,
              idUsuario: userId ?? idUsuario,
            ),
          ),
        );
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
              SizedBox(
                height: 126,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _gradientPlaceholder(title),
                          )
                        : _gradientPlaceholder(title),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.08),
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colores.text,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF6FE58F),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colores.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      capacity,
                      style: const TextStyle(
                        color: Colores.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
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

class _AlertsIcon extends StatelessWidget {
  const _AlertsIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_outlined),
        Positioned(
          right: -1,
          top: -1,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A5F),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colores.border, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertsPage extends StatelessWidget {
  const _AlertsPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colores.surface,
      child: const Center(
        child: Text(
          'Alertas',
          style: TextStyle(
            color: Colores.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({Key? key}) : super(key: key);

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
        '|',
        style: TextStyle(
          fontSize: 26,
          color: Colores.text,
        ),
      ),
    );
  }
}
