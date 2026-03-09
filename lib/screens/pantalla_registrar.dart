// import 'dart:ffi';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class PantallaRegistrar extends StatefulWidget {
  const PantallaRegistrar({super.key});

  @override
  State<PantallaRegistrar> createState() => _PantallaRegistrarState();
}

class _PantallaRegistrarState extends State<PantallaRegistrar> {
  bool _isChecked = false;
  final url = "http://localhost:8000/auth/register";
  final textControllerEmail = TextEditingController();
  final textController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  Future<Response>? response;
  void onRegistrarPressed() {
    // Acción al presionar el botón de inicio de sesión
    String body = jsonEncode({
      'name': textController.text,
      'email': textControllerEmail.text,
      'password': passwordController.text,
      'password_confirmation': passwordConfirmController.text,
    });
    Map<String, String> headers = {'Content-Type': 'application/json'};
    response = post(Uri.parse(url), body: body, headers: headers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantalla de Registrar"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 146, 152, 155),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color.fromRGBO(2, 56, 89, 1), Color.fromRGBO(0, 0, 0, 1)],
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(
                Icons.account_circle_rounded,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 3),
              Text(
                "Sign In ",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: const Color.fromRGBO(38, 101, 140, 1),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Nombre',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: textControllerEmail,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: const Color.fromRGBO(38, 101, 140, 1),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: const Color.fromRGBO(38, 101, 140, 1),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Contraseña',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordConfirmController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: const Color.fromRGBO(38, 101, 140, 1),
                  ),
                  border: OutlineInputBorder(),
                  hintText: 'Confirmar Contraseña',
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
              SizedBox(height: 5),
              CheckboxListTile(
                value: _isChecked,
                title: Text(
                  "Acepto terminos y condiciones",
                  style: TextStyle(color: Colors.white),
                ),
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón de inicio de sesión
                  onRegistrarPressed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 56, 89, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 130,
                    vertical: 15,
                  ),
                ),
                child: const Text('Registrarse'),
              ),
              SizedBox(height: 15),
              Text(
                "Crear cuenta con",
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón de inicio de sesión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 56, 89, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 85,
                    vertical: 15,
                  ),
                ),
                child: const Text('Crear cuenta con Google'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón de inicio de sesión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(2, 56, 89, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 75,
                    vertical: 15,
                  ),
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
