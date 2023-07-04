import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/my_remedies_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while fetching the user details
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Show an error message if there's an issue with retrieving the user details
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // User details retrieved successfully
          if (snapshot.hasData) {
            // Extract the user details from the snapshot
            Map<String, dynamic>? userData =
                snapshot.data?.data() as Map<String, dynamic>?;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          NetworkImage('https://example.com/profile-image.jpg'),
                    ),
                    const SizedBox(height: 24.0),
                    // ListTile(
                    //   title: const Text(
                    //     'User ID',
                    //     style: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   subtitle: Text(
                    //     uid ?? 'N/A',
                    //     style: const TextStyle(
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 16.0),
                    ListTile(
                      title: const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        userData?['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        userData?['email'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        userData?['age']?.toString() ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        userData?['gender'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      UserRemediesPage(userId: uid!)));
                            },
                            child: const Text("My Remedies"))
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            // User details not found
            return Scaffold(
              appBar: AppBar(
                title: const Text('Profile'),
              ),
              body: const Center(
                child: Text('User details not found.'),
              ),
            );
          }
        }
      },
    );
  }
}
