import 'package:intellicook/models/ingredient.dart';
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
  }

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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}