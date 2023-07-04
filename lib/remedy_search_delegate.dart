import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/remedy_details.dart';


class RemediesSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> remedies;

  RemediesSearchDelegate(this.remedies);

  @override
  String get searchFieldLabel => 'Search Remedies';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredRemedies = remedies.where((remedy) {
      final title = remedy['title'].toString().toLowerCase();
      final ingredients = (remedy['ingredients'] as List<dynamic>)
          .map((ingredient) => ingredient.toString().toLowerCase())
          .toList()
          .cast<String>();
      final symptoms = (remedy['symptoms'] as List<dynamic>)
          .map((symptom) => symptom.toString().toLowerCase())
          .toList()
          .cast<String>();

      return title.contains(query.toLowerCase()) ||
          ingredients
              .any((ingredient) => ingredient.contains(query.toLowerCase())) ||
          symptoms.any((symptom) => symptom.contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: filteredRemedies.length,
      itemBuilder: (context, index) {
        final remedy = filteredRemedies[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RemediesDetailPage(
                      remedyData: remedy,
                      userId: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredRemedies = remedies.where((remedy) {
      final title = remedy['title'].toString().toLowerCase();
      final ingredients = (remedy['ingredients'] as List<dynamic>)
          .map((ingredient) => ingredient.toString().toLowerCase())
          .toList()
          .cast<String>();
      final symptoms = (remedy['symptoms'] as List<dynamic>)
          .map((symptom) => symptom.toString().toLowerCase())
          .toList()
          .cast<String>();

      return title.contains(query.toLowerCase()) ||
          ingredients
              .any((ingredient) => ingredient.contains(query.toLowerCase())) ||
          symptoms.any((symptom) => symptom.contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: filteredRemedies.length,
      itemBuilder: (context, index) {
        final remedy = filteredRemedies[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RemediesDetailPage(
                      remedyData: remedy,
                      userId: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
