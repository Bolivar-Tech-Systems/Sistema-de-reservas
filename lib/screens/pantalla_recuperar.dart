import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/colores.dart';

class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {
  bool _isLoading = false;
  String? _errorMessage;
  final url = "http://localhost:8000/auth/forget-password";
  final textControllerEmail = TextEditingController();

  Future<void> onForgetPressed() async {
    if (textControllerEmail.text.isEmpty) {
      setState(() => _errorMessage = "Debes introducir un correo electronico");
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
        body: jsonEncode({"email": textControllerEmail.text}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correo enviado correctamente")),
        );
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = "Correo no encontrado";
        });
      } else {
        setState(() {
          _errorMessage = "Error inesperado";
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [Colores.background, Colors.black]),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.surface,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.login, color: Colores.iconActive),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.mark_email_unread,
                size: 100,
                color: Colores.iconActive,
              ),
              const SizedBox(height: 3),
              const Text(
                "Recuperar Contraseña",
                style: TextStyle(
                  fontSize: 25,
                  color: Colores.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Hola, ingresa el correo electronico vinculado con tu cuenta para enviarte el codigo de recuperacion",
                style: TextStyle(
                  fontSize: 15,
                  color: Colores.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: textControllerEmail,
                style: const TextStyle(color: Colores.text),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colores.primary),
                  border: OutlineInputBorder(),
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colores.textMuted),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _isLoading ? null : onForgetPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primaryDark,
                  foregroundColor: Colores.text,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colores.primary)
                    : const Text('Enviar correo'),
              ),
              SizedBox(height: 50),
              Column(
                children: [
                  Image.asset(
                    'assets/images/forgotp.png',
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
