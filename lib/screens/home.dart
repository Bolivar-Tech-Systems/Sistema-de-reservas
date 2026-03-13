import 'package:flutter/material.dart';
import 'pantalla_login.dart';

class PantallaHome extends StatefulWidget {
  const PantallaHome({super.key});

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

int _currentIndex = 0;

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
            colors: [
              Color.fromRGBO(2, 56, 89, 1),
              Color.fromRGBO(0, 0, 0, 0.9),
            ],
          ),
        ),
        padding: EdgeInsets.only(top: 25, left: 10, right: 20),
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
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: () {},
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
                          icon: Icon(Icons.exit_to_app_rounded),
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(96, 96, 96, 0.35),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),

                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_none_rounded), //
                          iconSize: 26,
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(96, 96, 96, 0.35),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
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
                            backgroundColor: Color.fromRGBO(96, 96, 96, 0.35),
                            foregroundColor: Color.fromRGBO(167, 235, 242, 1),
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
                  color: Color.fromRGBO(96, 96, 96, 0.35),
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
                          color: Color.fromRGBO(167, 235, 242, 1),
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
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
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
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
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
                    width: 190,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(96, 96, 96, 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Reservas activas",
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
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
                  SizedBox(width: 17),
                  Container(
                    padding: EdgeInsets.only(top: 2, left: 10, right: 5),
                    alignment: Alignment.topLeft,
                    width: 190,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(96, 96, 96, 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Ingresos de horario",
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
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
              SizedBox(height: 40),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 8),
                    child: Text(
                      "Recursos más usados",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(58, 58, 58, 0.1),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Cancha de futbol UTB",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            Text(
                              "Se necesitan minimo 10",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(136, 193, 192, 192),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro2.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Mesa de Ping Pong",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Disponible de 2-4 personas",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(
                                    136,
                                    193,
                                    192,
                                    192,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Cancha de futbol UTB",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Se necesitan minimo 10 personas",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(
                                    136,
                                    193,
                                    192,
                                    192,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(58, 58, 58, 0.1),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Cancha de futbol UTB",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            Text(
                              "Se necesitan minimo 10",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(136, 193, 192, 192),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro2.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Mesa de Ping Pong",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Disponible de 2-4 personas",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(
                                    136,
                                    193,
                                    192,
                                    192,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/images/nitro.jpg",
                                height: 160,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Cancha de futbol UTB",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            Text(
                              "Se necesitan minimo 10",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(136, 193, 192, 192),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
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
        color: Color.fromRGBO(61, 59, 59, 0.5),
        elevation: 8,
        //shadowColor: Color.fromRGBO(58, 58, 58, 0.3),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.79),
          selectedItemColor: Color.fromRGBO(167, 235, 242, 1),
          unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.498),
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
