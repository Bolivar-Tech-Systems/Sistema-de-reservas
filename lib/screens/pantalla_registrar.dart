import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/colores.dart';

class PantallaRegistrar extends StatefulWidget {
  const PantallaRegistrar({super.key});

  @override
  State<PantallaRegistrar> createState() => _PantallaRegistrarState();
}

class _PantallaRegistrarState extends State<PantallaRegistrar> {
  bool _isChecked = false;
  bool _isLoading = false;
  String? _errorMessage;

  final url = "http://localhost:8000/auth/register";
  final textController = TextEditingController();
  final textControllerEmail = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  Future<void> onRegistrarPressed() async {
    if (!_isChecked) {
      setState(() => _errorMessage = "Debes aceptar los términos y condiciones");
      return;
    }
    if (textController.text.isEmpty ||
        textControllerEmail.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty) {
      setState(() => _errorMessage = "Por favor completa todos los campos");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': textController.text,
          'email': textControllerEmail.text,
          'password': passwordController.text,
          'password_confirmation': passwordConfirmController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Registro exitoso — vuelve al login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Cuenta creada exitosamente! Inicia sesión.")),
          );
          Navigator.pop(context);
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['detail'] ?? 'Error al registrarse';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo conectar al servidor';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colores.background, Colors.black],
          ),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.account_circle_rounded, size: 100, color: Colores.icon),
              const SizedBox(height: 3),
              const Text(
                "Sign In",
                style: TextStyle(fontSize: 25, color: Colores.text, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colores.secondary),
                  border: OutlineInputBorder(),
                  hintText: 'Nombre',
                  hintStyle: TextStyle(color: Colores.textSecondary),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textControllerEmail,
                style: const TextStyle(color: Colores.text),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: Colores.secondary),
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colores.textSecondary),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colores.secondary),
                  border: OutlineInputBorder(),
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colores.textSecondary),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordConfirmController,
                obscureText: true,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colores.secondary),
                  border: OutlineInputBorder(),
                  hintText: 'Confirmar Contraseña',
                  hintStyle: TextStyle(color: Colores.textSecondary),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 5),
              CheckboxListTile(
                value: _isChecked,
                title: const Text("Acepto términos y condiciones", style: TextStyle(color: Colores.text)),
                onChanged: (bool? value) {
                  setState(() => _isChecked = value ?? false);
                },
              ),

              // Mensaje de error
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: _isLoading ? null : onRegistrarPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primary,
                  foregroundColor: Colores.textSecondary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colores.textSecondary)
                    : const Text('Registrarse'),
              ),
              const SizedBox(height: 15),
              Text("Crear cuenta con", style: TextStyle(fontSize: 14, color: Colores.textSecondary.withAlpha(130))),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primary,
                  foregroundColor: Colores.textSecondary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Crear cuenta con Google'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primary,
                  foregroundColor: Colores.textSecondary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Crear cuenta con Facebook'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}