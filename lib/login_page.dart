import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

enum AuthMode {SignUp, Login}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  AuthMode _authMode = AuthMode.SignUp;

  bool isLoading = false;

  // Rest of the code...

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.Login ? AuthMode.SignUp : AuthMode.Login;
      _nameController.clear();
      _ageController.clear();
      _genderController.clear();
    });
  }
  Future<void> _signUp(String name, String email, String password, int age, String gender) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
      });
      if(userCredential != null) {
        Navigator.of(context).pushNamed('/');
      }

      print('User signed up successfully');
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString() ?? "Something went wrong")));
    }
  }

  Future<void> _login(String email, String password) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(user != null) {
        Navigator.of(context).pushNamed('/');
      }
      print('User logged in successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString() ?? "Something went wrong")));
      print('Error logging in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_authMode == AuthMode.SignUp)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            if (_authMode == AuthMode.SignUp)
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
                keyboardType: TextInputType.number,
              ),
            if (_authMode == AuthMode.SignUp)
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                ),
              ),
            const SizedBox(height: 16.0),
            isLoading ? const Center(
              child: CircularProgressIndicator(),
            )  :
            ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                String name = _nameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;
                int age = int.tryParse(_ageController.text) ?? 0;
                String gender = _genderController.text;

                setState(() {
                  isLoading = true;
                });
                if (_authMode == AuthMode.Login) {
                  _login(email, password);
                } else {
                  _signUp(name, email, password, age, gender);
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign Up'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: _switchAuthMode,
              child: Text(
                _authMode == AuthMode.Login ? 'Switch to Sign Up' : 'Switch to Login',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      Map<String, dynamic>? userData = snapshot.data();
      return userData;
    } else {
      print('User data not found');
      return null;
    }
  } catch (e) {
    print('Error fetching user details: $e');
    return null;
  }
}

/*&
User? firebaseUser = FirebaseAuth.instance.currentUser;

if (firebaseUser != null) {
  String userId = firebaseUser.uid;
  print('User ID: $userId');
} else {
  print('No user found');
}
String userId = 'your_user_id'; // Replace with the actual user ID
Map<String, dynamic>? userDetails = await fetchUserDetails(userId);

if (userDetails != null) {
  // User data retrieved successfully
  // Access the user details using the 'userDetails' map
  String userName = userDetails['name'];
  int userAge = userDetails['age'];
  String userGender = userDetails['gender'];

  // Do something with the user details
  // ...
} else {
  // Failed to fetch user details
  // Handle the error or show an appropriate message
  // ...
}

 */
