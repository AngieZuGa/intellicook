// lib/modules/recipe_detail.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/helpers/database.dart';
import 'package:intellicook/services/spoonacular.dart';

class RecipeDetail extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetail({super.key, required this.recipe});

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  bool isFavorite = false;
  bool isLoading = true;
  Map<String, dynamic>? recipeInstructions;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadRecipeInstructions();
  }

  Future<void> _checkIfFavorite() async {
    final favorite = await DatabaseHelper.instance.isFavoriteRecipe(widget.recipe.id);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> _loadRecipeInstructions() async {
    try {
      final instructions = await SpoonacularService.getRecipeInstructions(widget.recipe.id);
      setState(() {
        recipeInstructions = instructions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        await DatabaseHelper.instance.deleteFavoriteRecipe(widget.recipe.id);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eliminado de favoritos')),
        );
      } else {
        await DatabaseHelper.instance.insertFavoriteRecipe(widget.recipe);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agregado a favoritos')),
        );
      }
      setState(() {
        isFavorite = !isFavorite;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.recipe.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.recipe.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.restaurant, size: 100),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Información básica
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          Icons.timer,
                          '${widget.recipe.readyInMinutes} min',
                          'Tiempo',
                        ),
                        _buildInfoItem(
                          Icons.signal_cellular_alt,
                          widget.recipe.difficulty,
                          'Dificultad',
                        ),
                        _buildInfoItem(
                          Icons.restaurant,
                          '${widget.recipe.usedIngredients.length + widget.recipe.missedIngredients.length}',
                          'Ingredientes',
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Ingredientes disponibles
                if (widget.recipe.usedIngredients.isNotEmpty) ...[
                  Text(
                    'Ingredientes disponibles ✅',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: widget.recipe.usedIngredients
                          .map((ingredient) => ListTile(
                                leading: Icon(Icons.check_circle, color: Colors.green),
                                title: Text(ingredient),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Ingredientes faltantes
                if (widget.recipe.missedIngredients.isNotEmpty) ...[
                  Text(
                    'Ingredientes faltantes ❌',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: widget.recipe.missedIngredients
                          .map((ingredient) => ListTile(
                                leading: Icon(Icons.cancel, color: Colors.red),
                                title: Text(ingredient),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Instrucciones
                Text(
                  'Instrucciones de preparación 👨‍🍳',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                
                if (isLoading)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (recipeInstructions != null)
                  _buildInstructions(recipeInstructions!)
                else
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Instrucciones no disponibles. Visita el sitio web de la receta para más detalles.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                
                SizedBox(height: 32),
                
                // Botón de acción
                if (widget.recipe.missedIngredients.isEmpty)
                  ElevatedButton.icon(
                    icon: Icon(Icons.kitchen),
                    label: Text('¡A cocinar!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Disfruta cocinando ${widget.recipe.title}!')),
                      );
                    },
                  )
                else
                  ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Agregar ingredientes faltantes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      _showShoppingList();
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInstructions(Map<String, dynamic> instructions) {
    final steps = instructions['analyzedInstructions'] ?? [];
    if (steps.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Instrucciones no disponibles para esta receta.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < steps[0]['steps'].length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[0]['steps'][i]['step'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showShoppingList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🛒 Lista de compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Ingredientes que necesitas comprar:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            ...widget.recipe.missedIngredients.map(
              (ingredient) => ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text(ingredient),
                trailing: Icon(Icons.add_shopping_cart),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}