import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_remedy/firebase_options.dart';
import 'package:home_remedy/profile_page.dart';

import 'add_remedy_page.dart';
import 'home.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),

        // Add any other theme customizations here
      ),
      routes: {
        '/addRemedy': (context) => const AddRemedyPage(),
        '/login': (context) => const LoginPage(),
        '/profile' : (context) => const ProfilePage()
      },
      initialRoute: '/',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading screen while checking the user's authentication state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.hasData) {
              // User is logged in, navigate to the home page
              return const Home();
            } else {
              // User is not logged in, navigate to the login page
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}

List<String> ingredients = [
  "Acupuncture",
  "Aloe Vera",
  "Apple Cider Vinegar",
  "Ashwagandha",
  "B-Vitamins",
  "Baking Soda",
  "Benzoyl Peroxide",
  "Boswellia",
  "Butterbur",
  "Cabbage Juice",
  "Caffeine",
  "Calendula",
  "Cayenne Pepper",
  "Chamomile",
  "Chondroitin",
  "Coconut Oil",
  "Coconut Water",
  "Comfrey Leaf",
  "CoQ10",
  "Cranberry Juice",
  "Eucalyptus",
  "Eucalyptus Oil",
  "Fennel",
  "Feverfew",
  "Fish Oil",
  "Garlic",
  "Ginger",
  "Ginseng",
  "Glucosamine",
  "Green Tea",
  "Honey",
  "Iron",
  "Lavender",
  "Lemon",
  "Lemon Balm",
  "Licorice",
  "Licorice Extract",
  "Licorice Root",
  "Magnesium",
  "Manuka Honey",
  "Marshmallow",
  "Marshmallow Root",
  "Melatonin",
  "Milk",
  "MSM",
  "Nasal Irrigation",
  "Neem Oil",
  "Nettle",
  "Nigella Sativa",
  "Papaya",
  "Passionflower",
  "Peppermint",
  "Peppermint Oil",
  "Probiotics",
  "Quercetin",
  "Retinol",
  "Rhodiola Rosea",
  "Riboflavin",
  "Sage",
  "Salicylic Acid",
  "Salt Water",
  "Slippery Elm",
  "Slippery Elm Bark",
  "Tea Tree Oil",
  "Thyme",
  "Turmeric",
  "Valerian Root",
  "Vitamin C",
  "White Willow Bark",
  "Wild Cherry Bark",
  "Willow Bark",
  "Witch Hazel",
  "Zinc",
];

List<String> symptoms = [
  "Acne",
  "Allergies",
  "Cough",
  "Fatigue",
  "Headache",
  "Healing Ulcers",
  "Healing Wounds",
  "Indigestion",
  "Insomnia",
  "Joint Pain",
  "Sore Throat",
];
