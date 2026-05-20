import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaAdminUsuarios extends StatefulWidget {
  const PantallaAdminUsuarios({super.key});

  @override
  State<PantallaAdminUsuarios> createState() => _PantallaAdminUsuariosState();
}

class _PantallaAdminUsuariosState extends State<PantallaAdminUsuarios> {
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _filtrados = [];
  bool _cargando = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();
    _searchCtrl.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsuarios() async {
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/auth/ListUsers'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        setState(() {
          _usuarios = data.cast<Map<String, dynamic>>();
          _filtrar();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  void _filtrar() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtrados = _usuarios.where((u) {
        final name = (u['name'] ?? u['nombre'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    });
  }

  Future<void> _eliminarUsuario(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colores.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Eliminar usuario?',
            style: TextStyle(color: Colores.text, fontWeight: FontWeight.w800)),
        content: const Text(
          'Esta acción es irreversible. Se eliminarán todos sus datos.',
          style: TextStyle(color: Colores.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/auth/DeleteUser/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado')),
        );
        _fetchUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.statusCode}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  Future<void> _cambiarRol(int userId, int currentRoleId) async {
    final newRole = currentRoleId == 1 ? 2 : 1;
    final label = newRole == 1 ? 'Administrador' : 'Usuario';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colores.surfaceAlt,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cambiar rol',
            style: TextStyle(color: Colores.text, fontWeight: FontWeight.w800)),
        content: Text(
          '¿Cambiar a $label?',
          style: const TextStyle(color: Colores.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colores.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final res = await http.put(
        Uri.parse('${AppConfig.baseUrl}/roles/update-role/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'role_id': newRole}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol cambiado a $label')),
        );
        _fetchUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${res.statusCode}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colores.background, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colores.border),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colores.text, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gestión de Usuarios',
                              style: TextStyle(
                                  color: Colores.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          Text('${_filtrados.length} usuarios',
                              style: const TextStyle(
                                  color: Colores.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colores.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colores.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colores.text, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      hintStyle: TextStyle(color: Colores.textMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: Colores.textMuted, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // List
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator(color: Colores.primary))
                    : _filtrados.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_outline_rounded, color: Colores.textMuted, size: 48),
                                SizedBox(height: 12),
                                Text('No se encontraron usuarios',
                                    style: TextStyle(color: Colores.textSecondary, fontSize: 14)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: Colores.primary,
                            onRefresh: _fetchUsuarios,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: _filtrados.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (_, i) => _buildUserCard(_filtrados[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final name = user['name'] ?? user['nombre'] ?? 'Sin nombre';
    final email = user['email'] ?? '';
    final roleId = user['role_id'] ?? 2;
    final isAdmin = roleId == 1;
    final userId = user['id'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colores.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colores.primary.withValues(alpha: 0.15)
                  : Colores.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAdmin ? Colores.primary.withValues(alpha: 0.4) : Colores.border,
              ),
            ),
            child: Center(
              child: Text(
                name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isAdmin ? Colores.primary : Colores.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(name.toString(),
                          style: const TextStyle(
                              color: Colores.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? Colores.primary.withValues(alpha: 0.15)
                            : Colores.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAdmin
                              ? Colores.primary.withValues(alpha: 0.4)
                              : Colores.border,
                        ),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'Usuario',
                        style: TextStyle(
                          color: isAdmin ? Colores.primary : Colores.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(email,
                    style: const TextStyle(
                        color: Colores.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _cambiarRol(userId, roleId),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colores.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: Colores.primary, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _eliminarUsuario(userId),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colores.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colores.danger, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
