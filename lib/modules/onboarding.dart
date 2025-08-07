import 'package:flutter/material.dart';
import 'package:intellicook/modules/home_screen.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
        child: Column(
          children: [
            Spacer(),
            Text("\u{1F373} ¡Bienvenido a IntelliCook!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Convierte tus ingredientes en platos deliciosos."),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen())),
              child: Text("Comenzar")
            )
          ],
        ),
      ),
    );
  }
}