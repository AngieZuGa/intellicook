// lib/models/recipe.dart (versión mejorada)
class Recipe {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final String difficulty;
  final List<String> usedIngredients;
  final List<String> missedIngredients;
  final String? summary;
  final double? healthScore;
  final List<String>? dishTypes;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.difficulty,
    required this.usedIngredients,
    required this.missedIngredients,
    this.summary,
    this.healthScore,
    this.dishTypes,
  });

  // Constructor para recetas de "findByIngredients"
  factory Recipe.fromJson(Map<String, dynamic> json) {
    final int minutes = json['readyInMinutes'] ?? 30;

    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: minutes,
      difficulty: _getDifficulty(minutes),
      usedIngredients: List<String>.from(
        json['usedIngredients']?.map((i) => i['name'] ?? i['originalName'] ?? '') ?? []
      ),
      missedIngredients: List<String>.from(
        json['missedIngredients']?.map((i) => i['name'] ?? i['originalName'] ?? '') ?? []
      ),
    );
  }

  // Constructor para recetas random
  factory Recipe.fromRandomJson(Map<String, dynamic> json) {
    final int minutes = json['readyInMinutes'] ?? 30;
    final List<dynamic> ingredients = json['extendedIngredients'] ?? [];

    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: minutes,
      difficulty: _getDifficulty(minutes),
      usedIngredients: ingredients.map((i) => i['name'] as String).toList(),
      missedIngredients: [],
      summary: json['summary'],
      healthScore: json['healthScore']?.toDouble(),
      dishTypes: List<String>.from(json['dishTypes'] ?? []),
    );
  }

  // Constructor para búsqueda de recetas
  factory Recipe.fromSearchJson(Map<String, dynamic> json) {
    final int minutes = json['readyInMinutes'] ?? 30;

    return Recipe(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      readyInMinutes: minutes,
      difficulty: _getDifficulty(minutes),
      usedIngredients: [],
      missedIngredients: [],
      summary: json['summary'],
      healthScore: json['healthScore']?.toDouble(),
      dishTypes: List<String>.from(json['dishTypes'] ?? []),
    );
  }

  static String _getDifficulty(int minutes) {
    if (minutes <= 15) return 'Fácil';
    if (minutes <= 30) return 'Medio';
    if (minutes <= 60) return 'Difícil';
    return 'Muy Difícil';
  }

  // Métodos útiles
  bool get canMakeNow => missedIngredients.isEmpty;
  bool get almostReady => missedIngredients.length <= 2 && missedIngredients.isNotEmpty;
  
  String get difficultyEmoji {
    switch (difficulty) {
      case 'Fácil':
        return '⭐';
      case 'Medio':
        return '⭐⭐';
      case 'Difícil':
        return '⭐⭐⭐';
      default:
        return '⭐⭐⭐⭐';
    }
  }

  String get timeCategory {
    if (readyInMinutes <= 15) return 'Rápido';
    if (readyInMinutes <= 30) return 'Normal';
    if (readyInMinutes <= 60) return 'Lento';
    return 'Muy Lento';
  }

  // Convertir a Map para base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'readyInMinutes': readyInMinutes,
      'difficulty': difficulty,
      'usedIngredients': usedIngredients.join(','),
      'missedIngredients': missedIngredients.join(','),
      'summary': summary,
      'healthScore': healthScore,
      'dishTypes': dishTypes?.join(','),
    };
  }

  // Crear desde Map de base de datos
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      image: map['image'],
      readyInMinutes: map['readyInMinutes'],
      difficulty: map['difficulty'],
      usedIngredients: (map['usedIngredients'] as String).split(',').where((s) => s.isNotEmpty).toList(),
      missedIngredients: (map['missedIngredients'] as String).split(',').where((s) => s.isNotEmpty).toList(),
      summary: map['summary'],
      healthScore: map['healthScore']?.toDouble(),
      dishTypes: map['dishTypes'] != null 
          ? (map['dishTypes'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : null,
    );
  }

  @override
  String toString() {
    return 'Recipe{id: $id, title: $title, readyInMinutes: $readyInMinutes, difficulty: $difficulty}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}