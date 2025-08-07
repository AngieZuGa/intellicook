import 'package:flutter/material.dart';
import 'package:intellicook/models/recipe.dart';


class RecipeDetail extends StatelessWidget {
  
  final Recipe recipe;

  const RecipeDetail({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.image),
            SizedBox(height: 16),
            Text('Tiempo: ${recipe.readyInMinutes} min', style: TextStyle(fontSize: 16)),
            Text('Dificultad: ${recipe.difficulty}', style: TextStyle(fontSize: 16)),
            Divider(height: 32),
            Text('Ingredientes disponibles:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.usedIngredients.map((i) => ListTile(leading: Icon(Icons.check), title: Text(i))),
            SizedBox(height: 16),
            Text('Ingredientes faltantes:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.missedIngredients.map((i) => ListTile(leading: Icon(Icons.close), title: Text(i))),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.favorite_border),
                label: Text('Agregar a Favoritos'),
                onPressed: () {
                  // Lógica futura: guardar localmente o en Firestore
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agregado a favoritos')));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}