import 'package:flutter/material.dart';
import 'package:intellicook/helpers/database.dart';
import 'package:intellicook/models/ingredient.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/modules/add_ingredient.dart';
import 'package:intellicook/services/spoonacular.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});
  @override
  InventoryState createState() => InventoryState();
}

class InventoryState extends State<Inventory> {
  List<Ingredient> ingredients = [];
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    final data = await DatabaseHelper.instance.getAllIngredients();
    setState(() {
      ingredients = data;
    });
  }

  Future<void> fetchRecipes() async {
    final ingredientNames = ingredients.map((e) => e.name).toList();
    final fetchedRecipes = await SpoonacularService.fetchRecipes(
      ingredientNames,
    );
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  List<Recipe> get canMakeNow =>
      recipes.where((r) => r.missedIngredients.isEmpty).toList();
  List<Recipe> get almostReady => recipes
      .where(
        (r) =>
            r.missedIngredients.length <= 2 && r.missedIngredients.isNotEmpty,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventario')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.quantity} ${item.unit}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await DatabaseHelper.instance.deleteIngredient(item.id!);
                      fetchIngredients();
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await fetchRecipes();
              showModalBottomSheet(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (_) => DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Puedes hacer ahora'),
                          Tab(text: 'Te falta poco'),
                          Tab(text: 'Todas'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildRecipeList(canMakeNow),
                            _buildRecipeList(almostReady),
                            _buildRecipeList(recipes),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text('Ver Recetas Sugeridas'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddIngredient()),
          );
          if (result == true) fetchIngredients();
        },
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> list) {
    return ListView(
      children: list.map((r) => ListTile(
        leading: Image.network(r.image, width: 50),
        title: Text(r.title),
        subtitle: Text('Tiempo: ${r.readyInMinutes} min - Dificultad: ${r.difficulty}'),
        onTap: () => _showRecipeDetail(r),
      )).toList(),
    );
  }

  void _showRecipeDetail(Recipe recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(recipe.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(recipe.image),
            SizedBox(height: 8),
            Text('Tiempo: ${recipe.readyInMinutes} minutos'),
            Text('Dificultad: ${recipe.difficulty}'),
            SizedBox(height: 12),
            Text('Tienes:'),
            ...recipe.usedIngredients.map((i) => Text('✔ $i')),
            SizedBox(height: 8),
            Text('Te falta:'),
            ...recipe.missedIngredients.map((i) => Text('✖ $i')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          )
        ],
      ),
    );
  }

}
