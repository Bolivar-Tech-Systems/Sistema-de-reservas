import 'package:flutter/material.dart';

class PantallaLogin extends StatelessWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantalla de Login"),
      ),
      body: const Center(
        child: Text("Aquí va el formulario de login"),
      ),
    );
  }
}