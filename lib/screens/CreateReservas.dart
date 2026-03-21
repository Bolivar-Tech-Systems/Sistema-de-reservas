import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../util/colores.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaCreateReserva extends StatefulWidget {
  PantallaCreateReserva({super.key});

  @override
  State<PantallaCreateReserva> createState() => _PantallaCreateReservaState();
}

class _PantallaCreateReservaState extends State<PantallaCreateReserva> {
  final nombre = TextEditingController();
  final descripcion = TextEditingController();
  String? _errorMSG;
  bool _cargando = false;

  final url = "http://127.0.0.1:8000/reservas/";

  Future<void> crearReserva() async {
    if (nombre.text.isEmpty || descripcion.text.isEmpty) {
      setState(() => _errorMSG = "Por favor completa todos los campos");
      return;
    }

    setState(() {
      _cargando = true;
      _errorMSG = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        setState(() => _errorMSG = "Sesión expirada, inicia sesión nuevamente");
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nombre.text,
          "description": descripcion.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _errorMSG = "Error ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _errorMSG = "No se pudo conectar al servidor");
    } finally {
      setState(() => _cargando = false);
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
        padding: EdgeInsets.only(top: 25, left: 10, right: 20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colores.primaryDark,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaCreateReserva(),
                      ),
                    );
                  },
                  child: Icon(Icons.arrow_back, color: Colores.text, size: 20),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Crea tu reserva",
              style: TextStyle(
                fontSize: 25,
                color: Colores.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nombre,
              style: TextStyle(color: Colores.text),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide.none,
                ),
                labelText: "Nombre de la reserva",
                labelStyle: TextStyle(color: Colores.textSecondary),
                prefixIcon: Icon(Icons.add, color: Colores.primary),
                fillColor: Colores.surface,
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descripcion,
              style: TextStyle(color: Colores.text),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide.none,
                ),
                labelText: "Descripcion de la reserva",
                labelStyle: TextStyle(color: Colores.textSecondary),
                prefixIcon: Icon(Icons.add, color: Colores.primary),
                fillColor: Colores.surface,
                filled: true,
              ),
            ),
            SizedBox(height: 30),
            if (_errorMSG != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _errorMSG!,
                  style: const TextStyle(color: Colores.danger, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.primaryDark,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: crearReserva,
              child: _cargando
                  ? const CircularProgressIndicator(color: Colores.primary)
                  : const Text(
                      "Crear Reserva",
                      style: TextStyle(fontSize: 16, color: Colores.text),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
