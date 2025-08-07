// lib/modules/favorites.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/helpers/database.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/modules/recipe_detail.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Recipe> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await DatabaseHelper.instance.getFavoriteRecipes();
      setState(() {
        favoriteRecipes = favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar favoritos: $e')),
      );
    }
  }

  Future<void> _removeFavorite(Recipe recipe) async {
    try {
      await DatabaseHelper.instance.deleteFavoriteRecipe(recipe.id);
      await _loadFavorites(); // Recargar la lista
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${recipe.title} eliminado de favoritos')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar favorito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("❤️ Mis Favoritos"),
        backgroundColor: Colors.red[50],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tienes recetas favoritas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Explora recetas y añade tus favoritas',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.restaurant),
                              ),
                            ),
                          ),
                          title: Text(
                            recipe.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '⏱️ ${recipe.readyInMinutes} min • ${recipe.difficulty}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'remove') {
                                _showRemoveConfirmation(recipe);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetail(recipe: recipe),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showRemoveConfirmation(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar favorito'),
        content: Text('¿Estás seguro de que quieres eliminar "${recipe.title}" de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFavorite(recipe);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}