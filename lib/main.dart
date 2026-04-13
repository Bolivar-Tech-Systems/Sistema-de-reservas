import 'package:flutter/material.dart';
import 'screens/pantalla_login.dart';
import 'screens/pantalla_auth.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sistema de Reservas",
      home: PantallaAuth(),
    );
  }
}
