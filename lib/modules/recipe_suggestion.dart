import 'package:flutter/material.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/modules/recipe_detail.dart';

class RecipeSuggestion extends StatelessWidget {
  const RecipeSuggestion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recetas Sugeridas")),
      body: FutureBuilder<List<Recipe>>(
        future: fetchSuggestedRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error al cargar recetas"));
          } else {
            final recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: Image.network(recipe.image),
                  title: Text(recipe.title),
                  subtitle: Text("${recipe.readyInMinutes} min - ${recipe.difficulty}"),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetail(recipe: recipe))),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<List<Recipe>> fetchSuggestedRecipes() async {
  // Aquí va la lógica de la API de Spoonacular
  return [];
}