import 'package:flutter/material.dart';
import 'pantalla_login.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
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
            colors: [Color.fromRGBO(2, 56, 89, 1), Color.fromRGBO(0, 0, 0, 1)],
          ),
        ),
        padding: EdgeInsets.only(top: 45, left: 10, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón de inicio de sesión con Google
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color.fromRGBO(2, 56, 89, 1),
                      foregroundColor: Color.fromRGBO(2, 56, 89, 1),
                      padding: EdgeInsets.all(10),
                    ),
                    child: Text(
                      'Mi actividad',
                      style: TextStyle(
                        color: Color.fromRGBO(167, 235, 242, 1),
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
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PantallaLogin(),
                              ),
                            );
                          },
                          icon: Icon(Icons.logout_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(2, 56, 89, 1),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(2, 56, 89, 1),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.settings_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(2, 56, 89, 1),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
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
                  color: Color.fromRGBO(2, 56, 89, 1),
                  borderRadius: BorderRadius.circular(10),
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
                          color: Color.fromARGB(255, 0, 229, 255),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Gestiona tus reservas",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Consulta, modifica o cancela tus reservas de manera fácil y rápida.",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(width: 2),
                  Container(
                    padding: EdgeInsets.only(top: 2, left: 10, right: 5),
                    alignment: Alignment.topLeft,
                    width: 174,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(2, 56, 89, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Reservas activas",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        SizedBox(width: 0.02),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.date_range_outlined),
                          style: IconButton.styleFrom(
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
                            iconSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.only(top: 2, left: 10, right: 5),
                    alignment: Alignment.topLeft,
                    width: 174,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(2, 56, 89, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Ingresos",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        SizedBox(width: 0.02),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.date_range_outlined),
                          style: IconButton.styleFrom(
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
                            iconSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 2, left: 5, right: 5),
                child: Row(
                  children: [
                    Text(
                      "Reservas Rápidas",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 150),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Ver todas",
                        style: TextStyle(
                          color: Color.fromRGBO(167, 235, 242, 1),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 90),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(2, 56, 89, 1),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/nitro.jpg",
                        height: 150,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: 30),
                      Image.asset(
                        "assets/images/nitro2.jpg",
                        height: 150,
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}


                // Text(
                //   "Bienvenido a la Pantalla de Home",
                //   style: TextStyle(
                //     fontSize: 25,
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
