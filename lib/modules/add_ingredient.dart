import 'package:flutter/material.dart';
import 'package:intellicook/helpers/database.dart';
import 'package:intellicook/models/ingredient.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({super.key});

  @override
  State<AddIngredient> createState() => AddIngredientState();
}

class AddIngredientState extends State<AddIngredient> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _quantity = 0;
  String _unit = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Ingrediente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _quantity = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Unidad'),
                onSaved: (value) => _unit = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Guardar'),
                onPressed: () async {
                  _formKey.currentState!.save();
                  final newIngredient = Ingredient(name: _name, quantity: _quantity, unit: _unit);
                  await DatabaseHelper.instance.insertIngredient(newIngredient);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, true);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}