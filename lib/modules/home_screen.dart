import 'package:flutter/material.dart';
import 'package:intellicook/modules/favorites.dart';
import 'package:intellicook/modules/inventory.dart';
import 'package:intellicook/modules/profile.dart';
import 'package:intellicook/modules/recipe_suggestion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Método para cambiar el índice desde los hijos
  void changeTabIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      Inventory(),
      RecipeSuggestion(),
      Favorites(),
      Profile(changeTab: (index) => changeTabIndex(index)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Recetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
