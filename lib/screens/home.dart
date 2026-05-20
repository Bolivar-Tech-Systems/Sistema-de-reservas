import 'package:flutter/material.dart';
import 'package:sistema_de_reservas/screens/DetalleReserva.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'CreateReservas.dart';
import 'horario_disponible.dart';
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

  List<Map<String, dynamic>> _categories = [];

  final GlobalKey<PantallaExplorarRecursosState> _explorarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _idUsuario = widget.idUsuario;
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/categorias/list/'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(
          data.map(
            (item) => {
              'label': item['nombre'],
              'icon': Icons.abc_rounded,
              'color': const Color(0xFF4F8CFF),
            },
          ),
        );
      });
    }
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      label: 'Explore',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_outlined),
      label: 'Bookings',
    ),
    BottomNavigationBarItem(icon: _AlertsIcon(), label: 'Alerts'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  List<Widget> get _pages => [
    _HomeTab(
      categories: _categories,
      idUsuario: _idUsuario,
    ),

    PantallaExplorarRecursos(key: _explorarKey, idUsuario: _idUsuario),

    PantallaMisReservas(),
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
    const accent = Color(0xFF4AA3FF);

    return Scaffold(
      backgroundColor: const Color(0xFF111417),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              elevation: 8,
              backgroundColor: accent,
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
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF12161A),
        elevation: 0,
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xFF758396),
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

  const _HomeTab({
    required this.categories,
    required this.idUsuario,
  });

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<Map<String, dynamic>> _recursos = [];
  bool _cargando = true;

final TextEditingController _searchController = TextEditingController();
List<Map<String, dynamic>> _resultadosBusqueda = [];
bool _buscando = false;

void _onSearch(String texto) {
  if (texto.isEmpty) {
    setState(() { _resultadosBusqueda = []; _buscando = false; });
    return;
  }
  setState(() {
    _buscando = true;
    _resultadosBusqueda = _recursos.where((r) {
      final nombre = (r['name'] ?? r['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(texto.toLowerCase());
    }).toList();
  });
}
  @override
  void initState() {
    super.initState();
    _fetchRecursos();
  }

Future<void> _fetchRecursos() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print('TOKEN: $token'); // ← agrega esto
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/reservas/list/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('STATUS: ${response.statusCode}'); // ← agrega esto
    print('BODY: ${response.body}'); // ← agrega esto
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _recursos = data.map((r) => Map<String, dynamic>.from(r as Map)).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  } catch (e) {
    print('ERROR: $e'); // ← agrega esto
    setState(() => _cargando = false);
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
    const textMain = Colors.white;
    const textSecondary = Color(0xFF94A3B8);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111417), Color(0xFF0F1418), Color(0xFF111417)],
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
              const Text(
                'Hi, Resident! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What would you like to reserve today?',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildSectionHeader(
                title: 'Categories',
                actionText: 'See All',
                onTap: () {},
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Featured Facilities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4AA3FF)))
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
                            tag: r['es_visible'] == true ? 'Disponible' : 'No disponible',
                            title: r['name'] ?? r['nombre'] ?? 'Recurso',
                            subtitle: r['description'] ?? r['descripcion'] ?? '',
                            recursoId: r['id'] as int,
                            idUsuario: widget.idUsuario,
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Text(
                        'Available Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
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
                            capacity: 'Capacity: ${r['capacidad'] ?? 0} People',
                            status: 'AVAILABLE',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF20262C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.flash_on_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const Text(
          'ResiBook',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        StreamBuilder<int>(
          stream: widget.idUsuario.isEmpty
              ? const Stream.empty()
              : NotificacionService().contarNoLeidas(widget.idUsuario),
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => Navigator.push(
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
    );
  }

Widget _buildSearchBar() {
  return Column(
    children: [
      Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2026),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF232B33)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF8E9BAA), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search facilities or equipment...',
                  hintStyle: TextStyle(color: Color(0xFF73808E), fontSize: 14),
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
                child: const Icon(Icons.close, color: Color(0xFF8E9BAA), size: 20),
              ),
          ],
        ),
      ),
      if (_buscando && _resultadosBusqueda.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2026),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF232B33)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _resultadosBusqueda.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFF232B33), height: 1),
            itemBuilder: (context, index) {
              final r = _resultadosBusqueda[index];
              final imagen = r['foto_principal'];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imagen != null && imagen.isNotEmpty
                      ? Image.network(imagen, width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: Colors.white54))
                      : const Icon(Icons.image_outlined, color: Colors.white54),
                ),
                title: Text(
                  r['nombre'] ?? 'Recurso',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  r['descripcion'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF758396), fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF4AA3FF)),
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
            color: const Color(0xFF1A2026),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF232B33)),
          ),
          child: const Center(
            child: Text('No se encontraron recursos',
                style: TextStyle(color: Color(0xFF758396), fontSize: 13)),
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
            color: Colors.white,
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
                  color: Color(0xFF8FA3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8FA3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3552),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF11486E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF7FC8FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR WEEK',
                  style: TextStyle(
                    color: Color(0xFF7FC8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '3 Reservations confirmed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Next: Rooftop Pool today at 4:00 PM',
                  style: TextStyle(
                    color: Color(0xFFC5D3E2),
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
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            style: const TextStyle(
              color: Color(0xFFB8C4D1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
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
          color: const Color(0xFF1B2127),
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
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2B333B),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: Colors.white54, size: 34),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF2B333B),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.white54, size: 34),
                      ),
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5DA9FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
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
                        color: Colors.white,
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
                        color: Color(0xFFE6EDF5),
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
          color: const Color(0xFF191E23),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF262D35)),
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
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF2A3138),
                              child: const Center(
                                child: Icon(Icons.image_outlined,
                                    color: Colors.white54, size: 32),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF2A3138),
                            child: const Center(
                              child: Icon(Icons.image_outlined,
                                  color: Colors.white54, size: 32),
                            ),
                          ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
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
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      capacity,
                      style: const TextStyle(
                        color: Color(0xFF98A6B5),
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
              border: Border.all(color: const Color(0xFF12161A), width: 1.5),
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
      color: const Color(0xFF111417),
      child: const Center(
        child: Text(
          'Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}