import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/colores.dart';
import '../util/app_config.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  Map<String, dynamic>? usuario;
  bool _cargando = true;
  bool _editando = false;
  bool _subiendoFoto = false;

  String? _fotoPerfilUrl;
  final ImagePicker _picker = ImagePicker();

  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  String? _errorMSG;

  @override
  void initState() {
    super.initState();
    fetchPerfil();
  }

  Future<void> fetchPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/auth/me/"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          usuario = data;
          nombreController.text = data['nombre'] ?? '';
          emailController.text = data['email'] ?? '';
          _fotoPerfilUrl = data['foto_perfil'];
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo conectar al servidor")),
        );
      }
    }
  }

  Future<void> _subirFotoPerfil() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _subiendoFoto = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return;

      final bytes = await picked.readAsBytes();
      final fileName = picked.path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'png' : 'jpeg';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${AppConfig.baseUrl}/images/upload-profile"),
      );
      request.headers["Authorization"] = "Bearer $token";
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType('image', mimeType),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        setState(() {
          _fotoPerfilUrl = data['foto_perfil'];
          if (usuario != null) usuario!['foto_perfil'] = _fotoPerfilUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto de perfil actualizada")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al subir foto: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión al subir foto")),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> guardarCambios() async {
    if (nombreController.text.isEmpty || emailController.text.isEmpty) {
      setState(() => _errorMSG = "Por favor completa todos los campos");
      return;
    }

    setState(() {
      _errorMSG = null;
      _cargando = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.patch(
        Uri.parse("${AppConfig.baseUrl}/auth/me/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nombre': nombreController.text,
          'email': emailController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _editando = false;
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado correctamente")),
        );
      } else {
        setState(() {
          _errorMSG = "Error al guardar: ${response.statusCode}";
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMSG = "No se pudo conectar al servidor";
        _cargando = false;
      });
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
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(color: Colores.primary),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Text(
                            'Mi Perfil',
                            style: TextStyle(
                              color: Colores.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _editando = !_editando),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colores.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colores.border),
                              ),
                              child: Icon(
                                _editando
                                    ? Icons.close_rounded
                                    : Icons.edit_outlined,
                                color: _editando
                                    ? Colores.danger
                                    : Colores.icon,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Avatar
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _editando && !_subiendoFoto
                                  ? _subirFotoPerfil
                                  : null,
                              child: Stack(
                                children: [
                                  _subiendoFoto
                                      ? Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colores.surface,
                                            border: Border.all(
                                              color: Colores.border,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colores.primary,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : _fotoPerfilUrl != null &&
                                              _fotoPerfilUrl!.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 45,
                                              backgroundImage: NetworkImage(
                                                _fotoPerfilUrl!,
                                              ),
                                              backgroundColor: Colores.surface,
                                            )
                                          : Container(
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colores.primaryDark
                                                    .withOpacity(0.15),
                                                border: Border.all(
                                                  color: Colores.border,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.account_circle_rounded,
                                                size: 50,
                                                color: Colores.iconActive,
                                              ),
                                            ),
                                  if (_editando && !_subiendoFoto)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colores.primaryDark,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 14,
                                          color: Colores.text,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              usuario?['nombre'] ?? 'Usuario',
                              style: const TextStyle(
                                color: Colores.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              usuario?['email'] ?? '',
                              style: const TextStyle(
                                color: Colores.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              '${usuario?['total_reservas'] ?? 0}',
                              'Reservas',
                              Icons.date_range_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              '${usuario?['activas'] ?? 0}',
                              'Activas',
                              Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              '${usuario?['favoritos'] ?? 0}',
                              'Favoritos',
                              Icons.star_outline_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Formulario o vista de lectura
                      if (_editando) ...[
                        _inputField(
                          controller: nombreController,
                          label: 'Nombre',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _inputField(
                          controller: emailController,
                          label: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        if (_errorMSG != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMSG!,
                              style: const TextStyle(
                                color: Colores.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: guardarCambios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colores.primaryDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                color: Colores.text,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colores.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colores.border),
                          ),
                          child: Column(
                            children: [
                              _infoRow(
                                Icons.person_outline_rounded,
                                'Nombre',
                                usuario?['nombre'] ?? 'No disponible',
                              ),
                              const Divider(
                                color: Colores.border,
                                height: 22,
                                thickness: 1,
                              ),
                              _infoRow(
                                Icons.email_outlined,
                                'Correo',
                                usuario?['email'] ?? 'No disponible',
                              ),
                              const Divider(
                                color: Colores.border,
                                height: 22,
                                thickness: 1,
                              ),
                              _infoRow(
                                Icons.calendar_month_outlined,
                                'Miembro desde',
                                usuario?['fecha_registro'] ?? 'No disponible',
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Cambiar contraseña
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Colores.border),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Colores.icon,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cambiar contraseña',
                                style: TextStyle(
                                  color: Colores.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _statCard(String valor, String label, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        children: [
          Icon(icono, color: Colores.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              color: Colores.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colores.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colores.text, fontSize: 14),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colores.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: Colores.primary, size: 18),
        filled: true,
        fillColor: Colores.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colores.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colores.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colores.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icono, String label, String valor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colores.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: Colores.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colores.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: const TextStyle(
                color: Colores.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
