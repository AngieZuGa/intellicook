import 'package:intellicook/models/ingredient.dart';
import 'package:intellicook/models/recipe.dart';
import 'package:intellicook/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('intelli_cook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_recipes (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        image TEXT NOT NULL,
        readyInMinutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        usedIngredients TEXT NOT NULL,
        missedIngredients TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        preferences TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE favorite_recipes (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          image TEXT NOT NULL,
          readyInMinutes INTEGER NOT NULL,
          difficulty TEXT NOT NULL,
          usedIngredients TEXT NOT NULL,
          missedIngredients TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute('''
        CREATE TABLE user_profile (
          id INTEGER PRIMARY KEY,
          name TEXT,
          email TEXT,
          preferences TEXT
        )
      ''');
    }
  }

  // Métodos para ingredientes
  Future<int> insertIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    return await db.insert('ingredients', ingredient.toMap());
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final db = await instance.database;
    final result = await db.query('ingredients');
    return result.map((map) => Ingredient.fromMap(map)).toList();
  }

  Future<int> deleteIngredient(int id) async {
    final db = await instance.database;
    return await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    return await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  // Métodos para recetas favoritas
  Future<int> insertFavoriteRecipe(Recipe recipe) async {
    final db = await instance.database;
    return await db.insert('favorite_recipes', {
      'id': recipe.id,
      'title': recipe.title,
      'image': recipe.image,
      'readyInMinutes': recipe.readyInMinutes,
      'difficulty': recipe.difficulty,
      'usedIngredients': recipe.usedIngredients.join(','),
      'missedIngredients': recipe.missedIngredients.join(','),
    });
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await instance.database;
    final result = await db.query('favorite_recipes', orderBy: 'created_at DESC');
    return result.map((map) => Recipe(
      id: map['id'] as int,
      title: map['title'] as String,
      image: map['image'] as String,
      readyInMinutes: map['readyInMinutes'] as int,
      difficulty: map['difficulty'] as String,
      usedIngredients: (map['usedIngredients'] as String).split(','),
      missedIngredients: (map['missedIngredients'] as String).split(','),
    )).toList();
  }

  Future<bool> isFavoriteRecipe(int recipeId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorite_recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteFavoriteRecipe(int recipeId) async {
    final db = await instance.database;
    return await db.delete('favorite_recipes', where: 'id = ?', whereArgs: [recipeId]);
  }

  // Métodos para perfil de usuario
  Future<int> saveUserProfile(String name, String email) async {
    final db = await instance.database;
    return await db.insert('user_profile', {
      'id': 1,
      'name': name,
      'email': email,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, String>?> getUserProfile() async {
    final db = await instance.database;
    final result = await db.query('user_profile', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return {
        'name': result.first['name'] as String,
        'email': result.first['email'] as String,
      };
    }
    return null;
  }
  
  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<int?> getIngredientsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ingredients');
    return Sqflite.firstIntValue(result);
  }

  Future<int?> getFavoritesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorites');
    return Sqflite.firstIntValue(result);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}