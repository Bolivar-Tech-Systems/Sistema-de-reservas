import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'pantalla_login.dart';
import 'horario_disponible.dart';
import 'crear_reserva.dart';
import '../util/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

int _currentIndex = 0;

class _PantallaHomeState extends State<PantallaHome> {
  List<dynamic>? reservas = [];
  SharedPreferences? sharedPreferences;
  Future<void> logout() async {
    final navigator = Navigator.of(context);
    final sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('access_token');
    await post(
      Uri.parse("http://192.168.1.54:8000/auth/logout"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    await sharedPreferences.remove('access_token');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PantallaLogin()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchReserva();
  }

  Future<void> fetchReserva() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('access_token');
      final response = await get(
        Uri.parse("http://192.168.1.54:8000/reservas"),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          reservas = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear reservas: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al crear reserva: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reservas == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                  Icon(
                    Icons.account_circle_rounded,
                    size: 60,
                    color: Colores.iconActive,
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colores.surface,
                      foregroundColor: Colores.surface,
                      padding: EdgeInsets.all(10),
                      side: BorderSide(color: Colores.border),
                    ),
                    child: Text(
                      'Mi actividad',
                      style: TextStyle(
                        color: Colores.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            logout();
                          },
                          icon: Icon(Icons.exit_to_app_rounded),
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.surface,
                            foregroundColor: Colores.icon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),

                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CrearReserva(),
                              ),
                            ).then((value) {
                              if (value == true) fetchReserva();
                            });
                          },
                          icon: Icon(Icons.add_circle_outline), //
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.surface,
                            foregroundColor: Colores.icon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),

                        // Settings
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.tune_rounded),
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: Colores.surface,
                            foregroundColor: Colores.icon,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Container(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: Colores.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colores.border),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Inicio",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colores.text,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Gestiona tus reservas",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, color: Colores.text),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Consulta, modifica o cancela tus reservas de manera fácil y rápida.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colores.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 2),
                    Container(
                      padding: EdgeInsets.only(top: 2, left: 10, right: 5),
                      alignment: Alignment.topLeft,
                      width: 190,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colores.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colores.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Reservas activas",
                            style: TextStyle(fontSize: 13, color: Colores.text),
                          ),
                          SizedBox(width: 0.02),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.date_range_outlined),
                            style: IconButton.styleFrom(
                              foregroundColor: Colores.iconActive,
                              iconSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 17),
                    SizedBox(width: 17),
                    Container(
                      padding: EdgeInsets.only(top: 2, left: 10, right: 5),
                      alignment: Alignment.topLeft,
                      width: 190,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colores.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colores.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Ingresos de horario",
                            style: TextStyle(fontSize: 13, color: Colores.text),
                          ),
                          SizedBox(width: 0.02),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.date_range_outlined),
                            style: IconButton.styleFrom(
                              foregroundColor: Colores.iconActive,
                              iconSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 8),
                    child: Text(
                      "Recursos disponibles en el momento",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colores.text,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colores.surface,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      ...List.generate(reservas!.length, (index) {
                        final reserva = reservas![index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 15, right: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaHorario(
                                        recurso: reserva['name'],
                                        imagen: "assets/images/nitro.jpg",
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    "assets/images/nitro.jpg",
                                    height: 160,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                reserva['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colores.text,
                                ),
                              ),
                              Text(
                                reserva['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colores.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //
      bottomNavigationBar: PhysicalModel(
        color: Colores.surface,
        elevation: 8,
        //shadowColor: Color.fromRGBO(58, 58, 58, 0.3),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colores.surface,
          selectedItemColor: Colores.primary,
          unselectedItemColor: Colores.icon,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favoritos"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          ],
        ),
      ),
    );
  }
}
