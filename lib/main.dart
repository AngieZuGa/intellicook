import 'package:flutter/material.dart';
import 'package:intellicook/modules/onboarding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliCook',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Onboarding(),
    );
  }
}

