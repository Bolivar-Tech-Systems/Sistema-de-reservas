import 'package:flutter/material.dart';

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
                    labelText: "Email",
                    labelStyle: TextStyle(color: Color.fromRGBO(84, 172, 191, 1)),
                    prefixIcon: Icon(Icons.email, color: Color.fromRGBO(84, 172, 191, 1)),
                    fillColor: Color.fromRGBO(2, 56, 89, 1),
                    filled: true
                  ),
                ),
                const SizedBox(height: 20),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color.fromRGBO(84, 172, 191, 1)),
                    prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(84, 172, 191, 1)),
                    fillColor: Color.fromRGBO(2, 56, 89, 1),
                    filled: true
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Remember me?", style: TextStyle(color: Colors.white, fontSize: 13)),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 10),
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón de inicio de sesión
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Iniciar Sesión'),
                ),         
              ],
            ),
          ),
        ),
      ),
    );
  }
}