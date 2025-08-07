import 'package:flutter/material.dart';
import 'package:intellicook/services/auth_service.dart';
import 'package:intellicook/modules/login.dart';
import 'package:intellicook/modules/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*await AuthService.deleteDatabaseManually();*/ // Solo para desarrollo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliCook',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          return const Login();
        }
      },
    );
  }
}
