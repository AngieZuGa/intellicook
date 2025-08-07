class Recipe {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final String difficulty;
  final List<String> usedIngredients;
  final List<String> missedIngredients;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.difficulty,
    required this.usedIngredients,
    required this.missedIngredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
  final int minutes = json['readyInMinutes'] ?? 0;

  return Recipe(
    id: json['id'],
    title: json['title'],
    image: json['image'],
    readyInMinutes: minutes,
    difficulty: _getDifficulty(minutes),
    usedIngredients: List<String>.from(json['usedIngredients'].map((i) => i['name'])),
    missedIngredients: List<String>.from(json['missedIngredients'].map((i) => i['name'])),
  );
}


  static String _getDifficulty(int minutes) {
    if (minutes <= 15) return 'Fácil';
    if (minutes <= 30) return 'Media';
    return 'Difícil';
  }
}