// lib/modules/profile.dart (versión mejorada)
import 'package:flutter/material.dart';
import 'package:intellicook/helpers/database.dart';
import 'package:intellicook/modules/login.dart';

class Profile extends StatefulWidget {
  final Function(int)? changeTab;
  
  const Profile({super.key, this.changeTab});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // ... (todo el resto de tu código permanece igual)

  Map<String, String>? userProfile;
  bool isLoading = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await DatabaseHelper.instance.getUserProfile();
      setState(() {
        userProfile = profile ?? {'name': 'Usuario Anónimo', 'email': ''};
        _nameController.text = userProfile!['name'] ?? '';
        _emailController.text = userProfile!['email'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userProfile = {'name': 'Usuario Anónimo', 'email': ''};
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      await DatabaseHelper.instance.saveUserProfile(
        _nameController.text,
        _emailController.text,
      );
      setState(() {
        userProfile = {
          'name': _nameController.text,
          'email': _emailController.text,
        };
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $e')),
      );
    }
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Editar Perfil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Guardar'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

  Future<Map<String, int>> _getStats() async {
    // Replace these with actual database queries as needed
    final ingredientsCount = await DatabaseHelper.instance.getIngredientsCount();
    final favoritesCount = await DatabaseHelper.instance.getFavoritesCount();
    return {
      'ingredients': ingredientsCount ?? 0,
      'favorites': favoritesCount ?? 0,
    };
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (el resto de tu Scaffold)
      appBar: AppBar(
        title: Text("👤 Mi Perfil"),
        backgroundColor: Colors.blue[50],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar y nombre
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.orange[200],
                            child: Text(
                              userProfile!['name']!.isNotEmpty
                                  ? userProfile!['name']!.substring(0, 1).toUpperCase()
                                  : '👤',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            userProfile!['name']!.isEmpty
                                ? 'Usuario Anónimo'
                                : userProfile!['name']!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (userProfile!['email']!.isNotEmpty)
                            Text(
                              userProfile!['email']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Editar Perfil'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: _showEditProfile,
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.favorite, color: Colors.red),
                          title: Text('Mis Favoritos'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Cambia al índice de Favoritos (2)
                            widget.changeTab?.call(2);
                          },
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.kitchen, color: Colors.green),
                          title: Text('Mi Inventario'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Cambia al índice de Inventario (0)
                            widget.changeTab?.call(0);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // ... (resto de tu código)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          FutureBuilder(
                            future: _getStats(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final stats = snapshot.data as Map<String, int>;
                                return Column(
                                  children: [
                                    _buildStatRow('🧺 Ingredientes', stats['ingredients']!),
                                    _buildStatRow('❤️ Recetas favoritas', stats['favorites']!),
                                  ],
                                );
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Información de la app
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.grey),
                          title: Text('Acerca de IntelliCook'),
                          subtitle: Text('Versión 1.0.0'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.help, color: Colors.grey),
                          title: Text('Ayuda y Soporte'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Función próximamente disponible')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Botón de cerrar sesión
                  ElevatedButton.icon(
                    onPressed: _showLogoutConfirmation,
                    icon: Icon(Icons.logout),
                    label: Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  
                  SizedBox(height: 20),

                ],
              ),
            ),
    );
  }
}