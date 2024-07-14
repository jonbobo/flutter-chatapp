import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_strategy/url_strategy.dart';
import 'config/firebase_options.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  setPathUrlStrategy(); // Enable URL-based navigation
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(_auth.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator while checking user status
        } else if (snapshot.hasError) {
          return const Text('Error checking user status');
        } else {
          final User? user = snapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Firebase Auth',
            initialRoute: user != null ? Routes.home : Routes.login,
            routes: Routes.routes, // Use the routes map
          );
        }
      },
    );
  }
}
