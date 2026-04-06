import 'package:flutter/material.dart';
import 'package:sistema_de_reservas/util/colores.dart';

class PantallaFinal extends StatelessWidget {
  const PantallaFinal({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colores.background, Colors.black]),
        ),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              const Icon(Icons.check, size: 100, color: Colores.iconActive),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: const Text(
                  "Tu contraseña ha sido cambiada correctamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colores.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 300,
                child: const Text(
                  "Bien hecho, tu contraseña fue cambiada de forma correcta, puedes cerrar esta pagina y regresar a la aplicacion para ingresar a tu cuenta con tu nueva contraseña",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colores.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(height: 30),
              Column(
                children: [
                  Image.asset(
                    'assets/images/finalp.png',
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
