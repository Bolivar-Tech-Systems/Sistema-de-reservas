// import 'dart:ffi';

import 'package:flutter/material.dart';

class PantallaRegistrar extends StatefulWidget {
  const PantallaRegistrar({super.key});

  @override
  State<PantallaRegistrar> createState() => _PantallaRegistrarState();
}

class _PantallaRegistrarState extends State<PantallaRegistrar> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantalla de Registrar"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(2, 56, 89, 1),
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
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.account_circle_rounded, size: 100, color: Colors.white),
            SizedBox(height: 10),
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
            SizedBox(height: 20),
            TextField(
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
            SizedBox(height: 20),
            TextField(
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
            SizedBox(height: 15),
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
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Acción al presionar el botón de inicio de sesión
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
    );
  }
}
