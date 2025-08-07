import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Usuario: anónimo"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Cerrar sesión o reset app
              },
              child: Text("Cerrar Sesión")
            )
          ],
        ),
      ),
    );
  }
}