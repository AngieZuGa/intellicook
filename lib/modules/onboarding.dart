// lib/modules/onboarding.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/modules/login.dart';


class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  PageController pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '🍳',
      title: '¡Bienvenido a IntelliCook!',
      subtitle: 'Tu asistente personal de cocina',
      description: 'Convierte tus ingredientes disponibles en deliciosas recetas personalizadas.',
    ),
    OnboardingPage(
      emoji: '🧺',
      title: 'Gestiona tu Inventario',
      subtitle: 'Control total de tus ingredientes',
      description: 'Añade, edita y organiza todos los ingredientes que tienes en casa.',
    ),
    OnboardingPage(
      emoji: '🍽️',
      title: 'Recetas Inteligentes',
      subtitle: 'Sugerencias personalizadas',
      description: 'Obtén recetas que puedes hacer ahora o con pocos ingredientes adicionales.',
    ),
    OnboardingPage(
      emoji: '❤️',
      title: 'Guarda tus Favoritas',
      subtitle: 'Nunca pierdas una buena receta',
      description: 'Marca tus recetas favoritas y accede a ellas cuando quieras.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de página superior
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),

            // Contenido del PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji grande
                        Text(
                          _pages[index].emoji,
                          style: TextStyle(fontSize: 100),
                        ),
                        
                        SizedBox(height: 32),
                        
                        // Título
                        Text(
                          _pages[index].title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Subtítulo
                        Text(
                          _pages[index].subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Descripción
                        Text(
                          _pages[index].description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (_currentPage < _pages.length - 1) ...[
                    // Botón Siguiente
                    ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Siguiente'),
                    ),
                    SizedBox(height: 12),
                    // Botón Saltar
                    TextButton(
                      onPressed: () => _navigateToLogin(),
                      child: Text('Saltar'),
                    ),
                  ] else ...[
                    // Botón Comenzar (última página)
                    ElevatedButton(
                      onPressed: () => _navigateToLogin(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('¡Comenzar a Cocinar!'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Login(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}