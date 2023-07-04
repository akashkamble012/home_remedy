import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/remedy_details.dart';

class UserRemediesPage extends StatefulWidget {
  final String userId;

  const UserRemediesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserRemediesPageState createState() => _UserRemediesPageState();
}

class _UserRemediesPageState extends State<UserRemediesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Remedies'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('remedies')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No remedies found.'),
            );
          }
          final data = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final remedyDocument = data[index];
                final remedyId = remedyDocument.id;
                final remedy = remedyDocument.data() as Map<String, dynamic>;
                remedy['remedyId'] = remedyId;

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                              showVoting: false,
                              userId: FirebaseAuth.instance.currentUser!.uid),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
