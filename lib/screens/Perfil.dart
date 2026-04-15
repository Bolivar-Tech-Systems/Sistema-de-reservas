import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
      }
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo conectar al servidor")),
      );
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
          SnackBar(content: Text("Perfil actualizado correctamente")),
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

  Widget _statCard(String valor, String label, IconData icono) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colores.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colores.border),
      ),
      child: Column(
        children: [
          Icon(icono, color: Colores.primary, size: 22),
          SizedBox(height: 6),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colores.text,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colores.textSecondary),
          ),
        ],
      ),
    );
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
        padding: EdgeInsets.only(left: 10, right: 20),
        child: _cargando
            ? Center(child: CircularProgressIndicator(color: Colores.primary))
            : SingleChildScrollView(
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
                          "Mi Perfil",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colores.text,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () => setState(() => _editando = !_editando),
                          icon: Icon(_editando ? Icons.close : Icons.edit_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.surface,
                            foregroundColor: _editando ? Colores.danger : Colores.icon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Avatar y nombre
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Icon(
                                Icons.account_circle_rounded,
                                size: 90,
                                color: Colores.iconActive,
                              ),
                              if (_editando)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colores.primaryDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.camera_alt_outlined, size: 14, color: Colores.text),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            usuario?['nombre'] ?? 'Usuario',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colores.text,
                            ),
                          ),
                          Text(
                            usuario?['email'] ?? '',
                            style: TextStyle(fontSize: 13, color: Colores.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Stats
                    Row(
                      children: [
                        Expanded(child: _statCard('${usuario?['total_reservas'] ?? 0}', 'Reservas', Icons.date_range_outlined)),
                        SizedBox(width: 10),
                        Expanded(child: _statCard('${usuario?['activas'] ?? 0}', 'Activas', Icons.check_circle_outline)),
                        SizedBox(width: 10),
                        Expanded(child: _statCard('${usuario?['favoritos'] ?? 0}', 'Favoritos', Icons.star_outline)),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Formulario de edición
                    if (_editando) ...[
                      TextField(
                        controller: nombreController,
                        style: TextStyle(color: Colores.text),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          labelText: "Nombre",
                          labelStyle: TextStyle(color: Colores.textSecondary),
                          prefixIcon: Icon(Icons.person_outline, color: Colores.primary),
                          fillColor: Colores.surface,
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colores.text),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colores.textSecondary),
                          prefixIcon: Icon(Icons.email_outlined, color: Colores.primary),
                          fillColor: Colores.surface,
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 14),
                      if (_errorMSG != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            _errorMSG!,
                            style: TextStyle(color: Colores.danger, fontSize: 13),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.primaryDark,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Guardar cambios", style: TextStyle(color: Colores.text)),
                      ),
                      SizedBox(height: 14),
                    ] else ...[
                      // Info de solo lectura
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colores.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colores.border),
                        ),
                        child: Column(
                          children: [
                            _infoRow(Icons.person_outline, "Nombre", usuario?['nombre'] ?? 'No disponible'),
                            Divider(color: Colores.border, height: 20),
                            _infoRow(Icons.email_outlined, "Email", usuario?['email'] ?? 'No disponible'),
                            Divider(color: Colores.border, height: 20),
                            _infoRow(Icons.calendar_month_outlined, "Miembro desde", usuario?['fecha_registro'] ?? 'No disponible'),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16),

                    // Cambiar contraseña
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.surface,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colores.border),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, color: Colores.textSecondary, size: 18),
                          SizedBox(width: 8),
                          Text("Cambiar contraseña", style: TextStyle(color: Colores.textSecondary)),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(IconData icono, String label, String valor) {
    return Row(
      children: [
        Icon(icono, color: Colores.primary, size: 18),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colores.textSecondary, fontSize: 11)),
            Text(valor, style: TextStyle(color: Colores.text, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
