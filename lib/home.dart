import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/remedy_details.dart';
import 'package:home_remedy/remedy_search_delegate.dart';

class Home extends StatefulWidget {
  static const String routeName = 'home';
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> ing = [];
  List<String> sym = [];
  List<Map<String, dynamic>> remedies = []; // List of all remedies

  @override
  void initState() {
    super.initState();
    fetchRemedies();
  }

  Future<void> fetchRemedies() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('remedies').get();
      print('SNAPSHOT RESPONSE FETCH REMEDIES ${snapshot.docs.toString()}');
      print('remedies length before cleaning: ${remedies.length}');
      remedies.clear();
      print('remedies length after cleaning: ${remedies.length}');

      remedies = snapshot.docs.map((doc) {
        final remedyId = doc.id;
        final data = doc.data();
        return {...data, 'remedyId': remedyId};
      }).toList();

      setState(() {});
      print('remedies length after adding: ${remedies.length}');
    } catch (e) {
      print("ERROR FETCHING REMEDIES: $remedies");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/addRemedy');
          fetchRemedies();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Home Remedy'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                print('User logged out successfully');
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              } catch (e) {
                print('Error logging out: $e');
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
        centerTitle: true,
      ),
      body: remedies.isNotEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onTap: () {
                      showSearch(
                          context: context,
                          delegate: RemediesSearchDelegate(remedies));
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: remedies.length,
                    itemBuilder: (context, index) {
                      final remedy = remedies[index];
                      print(remedy);
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            remedy['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Symptoms: ${remedy['symptoms'].join(' ')}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RemediesDetailPage(
                                  remedyData: remedy,
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            );
                            fetchRemedies();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}


void saveIngredientsAndSymptoms(
    List<String> ingredients, List<String> symptoms) async {
  try {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('remedy_data');
    // Save ingredients
    await collection.doc('ingredients').set({
      'list': ingredients,
    });

    // Save symptoms
    await collection.doc('symptoms').set({
      'list': symptoms,
    });

    print('Ingredients and Symptoms saved successfully!');
  } catch (e) {
    print('Error saving Ingredients and Symptoms: $e');
  }
}

Future<List<String>> fetchIngredients() async {
  List<String> ingredients = [];

  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('remedy_data')
        .doc('ingredients')
        .get();

    var data = snapshot.data() as Map<String, dynamic>;
    print('DATA  ing:::: $data');
    ingredients = List<String>.from(data['list']);
  } catch (e) {
    print('Error fetching ingredients: $e');
  }

  return ingredients;
}

Future<List<String>> fetchSymptoms() async {
  List<String> symptoms = [];

  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('remedy_data')
        .doc('symptoms')
        .get();

    var data = snapshot.data() as Map<String, dynamic>;
    print('DATA :::: $data');
    symptoms = List<String>.from(data['list']);
  } catch (e) {
    print('Error fetching symptoms: $e');
  }

  return symptoms;
}
