// lib/modules/recipe_suggestion.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/modules/recipe_detail.dart';
import 'package:intellicook/services/spoonacular.dart';
import 'package:intellicook/helpers/database.dart';

class RecipeSuggestion extends StatefulWidget {
  const RecipeSuggestion({super.key});

  @override
  State<RecipeSuggestion> createState() => _RecipeSuggestionState();
}

class _RecipeSuggestionState extends State<RecipeSuggestion>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Recipe> popularRecipes = [];
  List<Recipe> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPopularRecipes();
  }

  Future<void> _loadPopularRecipes() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final recipes = await SpoonacularService.getPopularRecipes(number: 20);

      if (!mounted) return;
      setState(() {
        popularRecipes = recipes;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    try {
      setState(() {
        isSearching = true;
        errorMessage = null;
      });

      final recipes = await SpoonacularService.searchRecipes(query, number: 15);

      setState(() {
        searchResults = recipes;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isSearching = false;
      });
    }
  }

  Future<void> _searchByIngredients() async {
    try {
      final ingredients = await DatabaseHelper.instance.getAllIngredients();

      if (ingredients.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agrega ingredientes a tu inventario primero'),
            action: SnackBarAction(
              label: 'Ir al inventario',
              onPressed: () {
                DefaultTabController.of(context).animateTo(0);
              },
            ),
          ),
        );
        return;
      }

      setState(() {
        isSearching = true;
        errorMessage = null;
      });

      final ingredientNames = ingredients.map((e) => e.name).toList();
      final recipes = await SpoonacularService.fetchRecipes(
        ingredientNames,
        number: 15,
      );

      setState(() {
        searchResults = recipes;
        isSearching = false;
      });

      // Cambiar a la pestaña de búsqueda
      _tabController.animateTo(1);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🍽️ Descubrir Recetas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Populares', icon: Icon(Icons.trending_up)),
            Tab(text: 'Búsqueda', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda y botón de ingredientes
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar recetas...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchRecipes('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _searchRecipes,
                  onSubmitted: _searchRecipes,
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _searchByIngredients,
                  icon: Icon(Icons.kitchen),
                  label: Text('Buscar con mis ingredientes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña de recetas populares
                _buildPopularRecipesTab(),

                // Pestaña de búsqueda
                _buildSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRecipesTab() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando recetas populares...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('Error al cargar recetas'),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPopularRecipes,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPopularRecipes,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: popularRecipes.length,
        itemBuilder: (context, index) {
          final recipe = popularRecipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildSearchTab() {
    if (isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando recetas...'),
          ],
        ),
      );
    }

    if (searchResults.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Busca recetas por nombre',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'O usa tus ingredientes para encontrar recetas personalizadas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No se encontraron recetas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final recipe = searchResults[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetail(recipe: recipe)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  recipe.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ),

            // Información de la receta
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Spacer(),

                    // Información adicional
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          '${recipe.readyInMinutes}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Text(
                          recipe.difficultyEmoji,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
