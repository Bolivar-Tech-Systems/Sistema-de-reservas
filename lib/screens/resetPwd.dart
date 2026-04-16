import 'package:flutter/material.dart';
import '../util/colores.dart';
import '../util/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPwd extends StatefulWidget {
  const ResetPwd({super.key});

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  final url = "${AppConfig.baseUrl}/auth/forget-password";
  final textController = TextEditingController();
  final passwordController = TextEditingController();
  bool code = false;
  String? _errorMessage;

  Future<void> resetPwd() async {
    if (textController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Ingrese el correo';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': textController.text}),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        // Registro exitoso — vuelve al login
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Correo enviado")));
          setState(() {
            code = true;
          });
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
    }
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
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colores.iconActive,
                ),
                Text(
                  !code ? "Restablecer contraseña" : "Ingrese Codigo",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colores.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                if (!code) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Ingrese su correo electronico registrado: ",
                          style: TextStyle(color: Colores.textMuted),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: textController,
                    style: TextStyle(color: Colores.text),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colores.textSecondary),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colores.primary,
                      ),
                      fillColor: Colores.surface,
                      filled: true,
                    ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colores.danger,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      resetPwd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.primaryDark,
                      foregroundColor: Colores.text,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Obtener codigo',
                      style: TextStyle(color: Colores.text, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colores.border),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colores.text, fontSize: 14),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Codigo enviado a su correo, ingrese el codigo: ",
                          style: TextStyle(
                            color: Colores.textMuted,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Código",
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colores.primary,
                      ),
                      // ... tu decoración
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        code = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.primaryDark,
                      foregroundColor: Colores.text,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Enviar codigo',
                      style: TextStyle(color: Colores.text, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colores.border),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colores.text, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => setState(() {
                      code = false;
                    }),
                    child: Row(
                      children: [
                        Text(
                          "Correo incorrecto?",
                          style: TextStyle(
                            color: Colores.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          " Corregir",
                          style: TextStyle(
                            color: Colores.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
