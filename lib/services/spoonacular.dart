import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class SpoonacularService {
  static const String apiKey = 'd06a2968603c413fb75a8c968d4bd37c';
  static const String baseUrl = 'https://api.spoonacular.com';

  static Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
    final String ingredientString = ingredients.join(',');
    final url = Uri.parse('$baseUrl/recipes/findByIngredients?ingredients=$ingredientString&number=10&apiKey=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}