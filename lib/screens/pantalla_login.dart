import 'package:flutter/material.dart';
import 'pantalla_registrar.dart';

class PantallaLogin extends StatelessWidget {
  const PantallaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
            Color.fromRGBO(2, 56, 89, 1),
            Color.fromRGBO(0, 0, 0, 1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                 ),
                const Text("Log In", style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 30),
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Color.fromRGBO(84, 172, 191, 1)),
                    prefixIcon: Icon(Icons.email_outlined, color: Color.fromRGBO(84, 172, 191, 1)),
                    fillColor: Color.fromRGBO(2, 56, 89, 1),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color.fromRGBO(84, 172, 191, 1)),
                    prefixIcon: Icon(Icons.lock_outline, color: Color.fromRGBO(84, 172, 191, 1)),
                    fillColor: Color.fromRGBO(2, 56, 89, 1),
                    filled: true
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón de inicio de sesión
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(84, 172, 191, 1),
                    foregroundColor: Color.fromRGBO(2, 56, 89, 1),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Iniciar Sesión', style: TextStyle(
                  color: Color.fromRGBO(167,235,242,1),
                  fontSize: 14,
                )),
                ),  
                const SizedBox(height: 20),
                const Text("Iniciar sesion con", style: TextStyle(
                  color: Color.fromRGBO(167,235,242,0.5),
                  fontSize: 13,
                )),
                const SizedBox(height: 10),
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
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text('Iniciar sesion con Google', style: TextStyle(
                    color: Color.fromRGBO(167,235,242,1),
                    fontSize: 14,
                  ),),
                ),       
                const SizedBox(height: 10),
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
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text('Iniciar sesion con Facebook', style: TextStyle(
                      color: Color.fromRGBO(167,235,242,1),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaRegistrar(),
                      ),
                    );
                  }, 
                  child: Text("¿No tienes una cuenta? Regístrate", style: TextStyle(
                    color: Color.fromRGBO(167,235,242,1),
                    fontSize: 14,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}