import 'package:flutter/material.dart';

class PantallaRegistrar extends StatelessWidget {
  const PantallaRegistrar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantalla de Registrar"),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(2, 56, 89, 1),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
                contentPadding: EdgeInsets.all(15),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contraseña',
                contentPadding: EdgeInsets.all(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
