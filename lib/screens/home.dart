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
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 45, left: 10, right: 20),
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
                          Navigator.pop(context,
                              MaterialPageRoute(builder: (context) => PantallaLogin())
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
                  )
                )
              ],
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 40, right: 20),
              child: Text(
                "Hola, Usuario!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
