// lib/main.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/modules/onboarding.dart';

void main() {
  runApp(const IntelliCookApp());
}

class IntelliCookApp extends StatelessWidget {
  const IntelliCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliCook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Esquema de colores principal
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange[600],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(
          secondary: Colors.deepOrange[400],
          surface: Colors.grey[50],
        ),
        
        // Configuración de AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        // Configuración de botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            elevation: 2,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Configuración de cards
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        
        // Configuración de inputs
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        
        // Configuración de la navegación inferior
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange[600],
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
        
        // Configuración de texto
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        
        // Configuración de floating action button
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
        ),
      ),
      
      home: const Onboarding(),
    );
  }
}

// Widget helper para mostrar errores
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget helper para mostrar estados de carga
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// Widget helper para estados vacíos
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}