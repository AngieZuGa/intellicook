import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicook/models/user.dart';
import 'package:intellicook/helpers/database.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Guardar sesión del usuario
  static Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id!);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
  }

  // Obtener usuario actual
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);

    if (userId != null && userName != null && userEmail != null) {
      return User(
        id: userId,
        name: userName,
        email: userEmail,
        password: '',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Registrar usuario
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Verificar si el email ya existe
      final emailExists = await DatabaseHelper.instance.emailExists(email);
      if (emailExists) {
        return {'success': false, 'message': 'El email ya está registrado'};
      }

      // Crear usuario
      final user = User(
        name: name,
        email: email,
        password: password, // En producción, encriptar la contraseña
        createdAt: DateTime.now(),
      );

      final userId = await DatabaseHelper.instance.insertUser(user);
      final newUser = user.copyWith(id: userId);

      // Guardar sesión
      await saveUserSession(newUser);

      return {'success': true, 'user': newUser};
    } catch (e) {
      return {'success': false, 'message': 'Error al registrar usuario'};
    }
  }

  // Iniciar sesión
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await DatabaseHelper.instance.authenticateUser(email, password);
      
      if (user != null) {
        await saveUserSession(user);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': 'Email o contraseña incorrectos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar sesión'};
    }
  }
}

// Extensión para User (agregar al archivo user.dart)
extension UserExtension on User {
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}