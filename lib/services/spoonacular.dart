// lib/services/spoonacular.dart (versión mejorada)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class SpoonacularService {
  static const String apiKey = 'd06a2968603c413fb75a8c968d4bd37c';
  static const String baseUrl = 'https://api.spoonacular.com';

  // Buscar recetas por ingredientes
  static Future<List<Recipe>> fetchRecipes(List<String> ingredients, {int number = 10}) async {
    try {
      final String ingredientString = ingredients.join(',');
      final url = Uri.parse(
        '$baseUrl/recipes/findByIngredients?ingredients=$ingredientString&number=$number&apiKey=$apiKey&ranking=1&ignorePantry=true'
      );

      print('Fetching recipes from: $url'); // Para debug
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else if (response.statusCode == 402) {
        throw Exception('Límite de API excedido. Intenta más tarde.');
      } else {
        throw Exception('Error al cargar recetas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchRecipes: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener recetas populares
  static Future<List<Recipe>> getPopularRecipes({int number = 10}) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/random?number=$number&apiKey=$apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recipes = data['recipes'] ?? [];
        
        return recipes.map((json) => Recipe.fromRandomJson(json)).toList();
      } else {
        throw Exception('Error al cargar recetas populares: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPopularRecipes: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener información detallada de una receta
  static Future<Map<String, dynamic>> getRecipeInformation(int recipeId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=false'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener información de la receta');
      }
    } catch (e) {
      print('Error in getRecipeInformation: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener instrucciones de una receta
  static Future<Map<String, dynamic>> getRecipeInstructions(int recipeId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=false'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'analyzedInstructions': data['analyzedInstructions'] ?? [],
          'instructions': data['instructions'] ?? '',
          'summary': data['summary'] ?? '',
        };
      } else {
        throw Exception('Error al obtener instrucciones');
      }
    } catch (e) {
      print('Error in getRecipeInstructions: $e');
      return {};
    }
  }

  // Buscar recetas por nombre
  static Future<List<Recipe>> searchRecipes(String query, {int number = 10}) async {
    try {
      final url = Uri.parse(
        '$baseUrl/recipes/complexSearch?query=$query&number=$number&apiKey=$apiKey&addRecipeInformation=true'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recipes = data['results'] ?? [];
        
        return recipes.map((json) => Recipe.fromSearchJson(json)).toList();
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchRecipes: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}