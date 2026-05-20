import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaAdminCategorias extends StatefulWidget {
  const PantallaAdminCategorias({super.key});

  @override
  State<PantallaAdminCategorias> createState() => _PantallaAdminCategoriasState();
}

class _PantallaAdminCategoriasState extends State<PantallaAdminCategorias> {
  List<Map<String, dynamic>> _categorias = [];
  bool _cargando = true;
  String _errorMsg = '';

  // Iconos disponibles para el selector
  final List<Map<String, dynamic>> _iconosDisponibles = [
    {'key': 'meeting_room', 'icon': Icons.meeting_room_rounded, 'label': 'Sala de Juntas'},
    {'key': 'theater_comedy', 'icon': Icons.theater_comedy_rounded, 'label': 'Auditorio/Teatro'},
    {'key': 'sports_soccer', 'icon': Icons.sports_soccer_rounded, 'label': 'Cancha/Deporte'},
    {'key': 'work', 'icon': Icons.work_rounded, 'label': 'Oficina/Trabajo'},
    {'key': 'science', 'icon': Icons.science_rounded, 'label': 'Laboratorio'},
    {'key': 'restaurant', 'icon': Icons.restaurant_rounded, 'label': 'Restaurante'},
    {'key': 'pool', 'icon': Icons.pool_rounded, 'label': 'Piscina'},
    {'key': 'hotel', 'icon': Icons.hotel_rounded, 'label': 'Habitación'},
    {'key': 'local_parking', 'icon': Icons.local_parking_rounded, 'label': 'Parqueadero'},
    {'key': 'fitness_center', 'icon': Icons.fitness_center_rounded, 'label': 'Gimnasio'},
    {'key': 'celebration', 'icon': Icons.celebration_rounded, 'label': 'Salón Social'},
    {'key': 'computer', 'icon': Icons.computer_rounded, 'label': 'Sala de Sistemas'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    setState(() {
      _cargando = true;
      _errorMsg = '';
    });
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/categorias/list/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _categorias = data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
            _cargando = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMsg = 'Error al cargar categorías (${response.statusCode})';
            _cargando = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error de conexión: $e';
          _cargando = false;
        });
      }
    }
  }

  IconData _getIconData(String key) {
    final match = _iconosDisponibles.firstWhere(
      (item) => item['key'] == key,
      orElse: () => {'icon': Icons.category_rounded},
    );
    return match['icon'] as IconData;
  }

  Future<void> _eliminarCategoria(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colores.surface,
        title: const Text('Eliminar Categoría', style: TextStyle(color: Colores.text)),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta categoría? Esto podría afectar a los recursos asociados.',
          style: TextStyle(color: Colores.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colores.danger),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/categorias/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría eliminada correctamente')),
        );
        _fetchCategorias();
      } else {
        final err = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err['detail'] ?? 'Error al eliminar categoría')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _abrirFormulario({Map<String, dynamic>? categoria}) {
    final isEdit = categoria != null;
    final nombreController = TextEditingController(text: isEdit ? categoria['nombre'] : '');
    final descController = TextEditingController(text: isEdit ? categoria['descripcion'] : '');
    String selectedIconKey = isEdit ? (categoria['icono'] ?? 'meeting_room') : 'meeting_room';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colores.border)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colores.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isEdit ? 'Editar Categoría' : 'Nueva Categoría',
                        style: const TextStyle(
                          color: Colores.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Nombre
                      const Text('Nombre', style: TextStyle(color: Colores.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.border),
                        ),
                        child: TextField(
                          controller: nombreController,
                          style: const TextStyle(color: Colores.text, fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            hintText: 'Ej. Sala de Reuniones',
                            hintStyle: TextStyle(color: Colores.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      const Text('Descripción', style: TextStyle(color: Colores.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colores.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.border),
                        ),
                        child: TextField(
                          controller: descController,
                          maxLines: 3,
                          style: const TextStyle(color: Colores.text, fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            hintText: 'Descripción del uso de la categoría...',
                            hintStyle: TextStyle(color: Colores.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Selector de Icono
                      const Text('Selecciona un Icono', style: TextStyle(color: Colores.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _iconosDisponibles.length,
                          itemBuilder: (context, idx) {
                            final item = _iconosDisponibles[idx];
                            final isSel = selectedIconKey == item['key'];
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedIconKey = item['key'];
                                });
                              },
                              child: Tooltip(
                                message: item['label'],
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSel ? Colores.primaryDark : Colores.surfaceAlt,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSel ? Colores.primary : Colores.border),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: isSel ? Colors.white : Colores.icon,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón Guardar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final nombre = nombreController.text.trim();
                            final descripcion = descController.text.trim();
                            if (nombre.isEmpty || descripcion.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor completa todos los campos')),
                              );
                              return;
                            }

                            try {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('access_token') ?? '';

                              final body = {
                                'nombre': nombre,
                                'descripcion': descripcion,
                                'icono': selectedIconKey,
                              };

                              final url = isEdit
                                  ? '${AppConfig.baseUrl}/categorias/${categoria['id']}'
                                  : '${AppConfig.baseUrl}/categorias/';

                              final res = isEdit
                                  ? await http.put(
                                      Uri.parse(url),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $token',
                                      },
                                      body: jsonEncode(body),
                                    )
                                  : await http.post(
                                      Uri.parse(url),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $token',
                                      },
                                      body: jsonEncode(body),
                                    );

                              if (res.statusCode == 200 || res.statusCode == 201) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(isEdit ? 'Categoría actualizada' : 'Categoría creada')),
                                );
                                _fetchCategorias();
                              } else {
                                final err = jsonDecode(res.body);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err['detail'] ?? 'Error al guardar categoría')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Guardar Categoría',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
            children: [
              _buildHeader(),
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator(color: Colores.primary))
                    : _errorMsg.isNotEmpty
                        ? _buildErrorWidget()
                        : _categorias.isEmpty
                            ? _buildEmptyState()
                            : _buildListaCategorias(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colores.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colores.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categorías',
                  style: TextStyle(
                    color: Colores.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Gestión del catálogo principal',
                  style: TextStyle(
                    color: Colores.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colores.danger, size: 48),
          const SizedBox(height: 12),
          Text(_errorMsg, style: const TextStyle(color: Colores.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchCategorias,
            style: ElevatedButton.styleFrom(backgroundColor: Colores.primaryDark),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(Icons.category_outlined, color: Colores.textMuted, size: 44),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay categorías registradas',
            style: TextStyle(color: Colores.textSecondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCategorias() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: _categorias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cat = _categorias[index];
        final iconKey = cat['icono'] ?? 'meeting_room';
        final nombre = cat['nombre'] ?? 'Sin nombre';
        final desc = cat['descripcion'] ?? 'Sin descripción';
        final id = cat['id'] as int;

        return Container(
          decoration: BoxDecoration(
            color: Colores.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colores.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colores.border),
                ),
                child: Icon(
                  _getIconData(iconKey),
                  color: Colores.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        color: Colores.text,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colores.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colores.primary, size: 20),
                    onPressed: () => _abrirFormulario(categoria: cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, color: Colores.danger, size: 20),
                    onPressed: () => _eliminarCategoria(id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
