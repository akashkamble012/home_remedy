import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddRemedyPage extends StatefulWidget {
  const AddRemedyPage({Key? key}) : super(key: key);

  @override
  _AddRemedyPageState createState() => _AddRemedyPageState();
}

class _AddRemedyPageState extends State<AddRemedyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _noteController = TextEditingController();
  final _ingredientsController = TextEditingController();
  List<String> _ingredients = []; // List to store ingredients

  @override
  void dispose() {
    _titleController.dispose();
    _symptomsController.dispose();
    _instructionsController.dispose();
    _ingredientsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  Future<void> _addRemedy() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final symptom = _symptomsController.text;
      final instructions = _instructionsController.text;
      final note = _noteController.text;
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one Ingredient')),
        );
        return;
      }
      final effectiveness = await getEffectiveness(
        ingredients: _ingredients,
        symptom: symptom,
      );
      print('effective_ness: $effectiveness');

      final user = FirebaseAuth.instance.currentUser;
      final userId = user != null ? user.uid : '';

      final body = {
        'userId': userId,
        'title': title,
        'symptoms': [symptom],
        'ingredients': _ingredients,
        'instructions': instructions,
        'note': note,
        'effectiveness': effectiveness ?? 'Unknown',
        'votes': {
          'effective': 0,
          'notEffective': 0,
          'unknown': 0,
        },
      };
      print("BODY :: $body");
      FirebaseFirestore.instance
          .collection('remedies')
          .add(body)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remedy added successfully')),
        );
        // Reset form fields
        _titleController.clear();
        _symptomsController.clear();
        _instructionsController.clear();
        _noteController.clear();
        Navigator.of(context).pop();
      }).catchError((error) {
        // Error adding remedy
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding remedy')),
        );
      });
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter required fields')),
      );
    }
  }
  Future<String?> getEffectiveness(
      {required List<String> ingredients, required String symptom}) async {
    const url = 'https://akamble012.pythonanywhere.com/predict';
    final body = jsonEncode({"symptom": symptom, "ingredients": ingredients});
    print('Request Body :: $body');

    try {
      final response = await http.post(Uri.parse(url), body: body, headers: {
        'Content-Type': 'application/json',
      });
      print('RESPONSE FOR EFFECTIVENESS  ${response.body}');
      final statusCode = response.statusCode;
      if (statusCode >= 400) {
        print('Error Thrown for effectiveness');
        return null;
      }
      final responseData = jsonDecode(response.body);

      return responseData['overall_effectiveness'];
    } catch (e) {
      print('Error Thrown for effectiveness: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Remedy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _symptomsController,
                  decoration: const InputDecoration(
                      labelText: 'Symptom'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter symptom';
                    }
                    return null;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ingredients',
                    suffixIcon: Icon(Icons.add),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _ingredients.add(value);
                      _ingredientsController.clear();
                    });
                  },
                  controller: _ingredientsController,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'Added Ingredients:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    for (var ingredient in _ingredients) Text('- $ingredient'),
                  ],
                ),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'Instructions'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter instructions';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                const SizedBox(height: 16.0),
                StatefulBuilder(
                  builder: (context, state) => isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
// Get a reference to the 'remedies' collection
//                             final CollectionReference remediesRef = FirebaseFirestore.instance.collection('remedies');
//
// // Create a batch
//                             final WriteBatch batch = FirebaseFirestore.instance.batch();
//
// // Query the collection to get all documents
//                             final QuerySnapshot querySnapshot = await remediesRef.get();
//
// // Iterate through each document and update the 'userId' field
//                             for (final DocumentSnapshot doc in querySnapshot.docs) {
//                               batch.update(doc.reference, { 'votes': {
//                               'effective': {
//                               'count': 0,
//                               'users': [],
//                               },
//                               'notEffective': {
//                               'count': 0,
//                               'users': [],
//                               },
//                               'unknown': {
//                               'count': 0,
//                               'users': [],
//                               },
//                               },});
//                             }

// Commit the batched write operation
//              //               await batch.commit();


                            FocusScope.of(context).unfocus();
                            state(() => isLoading = true);
                            await _addRemedy();
                            state(() => isLoading = false);
                          },
                          child: const Text('Add Remedy'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
