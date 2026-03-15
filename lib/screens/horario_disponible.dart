import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sistema_de_reservas/screens/home.dart';
import 'pantalla_login.dart';
import '../util/colores.dart';

class PantallaHorario extends StatefulWidget {
  final String recurso;
  final String imagen;

  const PantallaHorario({
    required this.recurso,
    required this.imagen,
    super.key,
  });

  @override
  State<PantallaHorario> createState() => _PantallaHorario();
}

class _PantallaHorario extends State<PantallaHorario> {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        MaterialPageRoute(builder: (context) => PantallaHome()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.text,
                      // minimumSize: Size(40, 50),
                      // maximumSize: Size(40, 50),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Horario disponible',
                    style: TextStyle(
                      color: Colores.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colores.border),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        widget.imagen,
                        height: 160,
                        width: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        widget.recurso,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colores.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Selecciona una hora disponible",
                style: TextStyle(color: Colores.text, fontSize: 15),
              ),
              SizedBox(height: 20),
              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("08:00 AM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("09:00 AM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("10:00 AM"),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("11:00 AM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("12:00 PM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("01:00 PM"),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("02:00 PM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("03:00 PM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("04:00 PM"),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("05:00 PM"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: Colores.primaryDark,
                              width: 1,
                            ),
                            backgroundColor: Colores.border,
                            foregroundColor: Colores.text,
                          ),
                          onPressed: () {},
                          child: Text("06:00 PM"),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colores.primaryDark,
                        foregroundColor: Colores.text,
                        minimumSize: Size(360, 50),
                      ),
                      onPressed: () {},
                      child: Text("Reservar"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
