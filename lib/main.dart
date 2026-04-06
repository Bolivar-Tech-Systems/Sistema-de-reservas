import 'package:flutter/material.dart';
import 'screens/pantalla_login.dart';
import 'screens/pantalla_reset.dart';
import 'screens/pantalla_final.dart';

void main() {
  final uri = Uri.base;

  Widget startScreen;

  final token = uri.queryParameters['token'];
  final screen = uri.queryParameters['screen'];

  if (token != null) {
    startScreen = const Reset();
  } else if (screen == "home") {
    startScreen = const PantallaFinal();
  } else {
    startScreen = const PantallaLogin();
  }

  runApp(MainApp(startScreen: startScreen));
}

class MainApp extends StatelessWidget {
  final Widget startScreen;

  const MainApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sistema de Reservas",
      home: startScreen,
    );
  }
}
