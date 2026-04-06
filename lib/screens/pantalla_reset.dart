import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../util/colores.dart';
import 'dart:html' as html;

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  String? _errorMessage;
  String? token;
  bool _isLoading = false;

  final url = "http://localhost:8000/auth/reset-password";

  final textControllerNewPassword = TextEditingController();
  final textControllerPasswordConfirm = TextEditingController();

  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();

    // web
    if (kIsWeb) {
      final uri = Uri.base;
      final t = uri.queryParameters['token'];

      if (t != null) {
        token = t;
      }
    }

    // movil
    if (!kIsWeb) {
      _appLinks = AppLinks();

      _appLinks.uriLinkStream.listen((Uri uri) {
        final t = uri.queryParameters['token'];

        if (t != null) {
          setState(() {
            token = t;
          });
        }
      });

      getInitialLink();
    }
  }

  Future<void> getInitialLink() async {
    if (kIsWeb) return;

    final uri = await _appLinks.getInitialAppLink();

    if (uri != null) {
      final t = uri.queryParameters['token'];

      if (t != null) {
        setState(() {
          token = t;
        });
      }
    }
  }

  Future<void> onResetPressed() async {
    if (textControllerNewPassword.text.isEmpty ||
        textControllerPasswordConfirm.text.isEmpty) {
      setState(() {
        _errorMessage = "Ingrese ambos requisitos";
      });
      return;
    }

    if (textControllerNewPassword.text != textControllerPasswordConfirm.text) {
      setState(() {
        _errorMessage = "Las contraseñas no coinciden";
      });
      return;
    }

    if (token == null) {
      setState(() {
        _errorMessage = "Token invalido";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "secret_token": token,
          "new_password": textControllerNewPassword.text,
          "confirm_password": textControllerPasswordConfirm.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La contraseña ha sido actualizada correctamente"),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        html.window.location.href = "http://localhost:5000/?screen=home";
      } else {
        setState(() {
          _errorMessage = "Error al cambiar la contraseña";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Error de conexion";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    textControllerNewPassword.dispose();
    textControllerPasswordConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [Colores.background, Colors.black]),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Icon(
                Icons.lock_reset,
                size: 100,
                color: Colores.iconActive,
              ),

              const SizedBox(height: 20),

              const Text(
                "Restablecer Contraseña",
                style: TextStyle(
                  fontSize: 25,
                  color: Colores.text,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: textControllerNewPassword,
                obscureText: true,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colores.primary),
                  hintText: 'Nueva contraseña',
                  hintStyle: TextStyle(color: Colores.textMuted),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: textControllerPasswordConfirm,
                obscureText: true,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: Colores.primary),
                  hintText: 'Confirmar contraseña',
                  hintStyle: TextStyle(color: Colores.textMuted),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : onResetPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primaryDark,
                  foregroundColor: Colores.text,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colores.primary)
                    : const Text("Cambiar contraseña"),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  Image.asset(
                    'assets/images/resetp.png',
                    width: 600,
                    height: 400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
