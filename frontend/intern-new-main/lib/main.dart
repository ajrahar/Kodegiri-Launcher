import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Kodegiri/universal_screen/link_provider.dart'; // Ensure the import path is correct
import 'admin_screens/home_screen.dart';
import 'universal_screen/login_screen.dart';
import 'universal_screen/splash_screen.dart'; // Import the SplashScreen 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LinkProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodegiri App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        // Add other routes here
      },
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}
