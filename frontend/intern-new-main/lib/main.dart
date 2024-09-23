import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Kodegiri/universal_screen/link_provider.dart'; 
import 'admin_screens/home_screen.dart';
import 'universal_screen/login_screen.dart';
import 'universal_screen/splash_screen.dart'; 

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
      home: SplashScreen(), 
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(), 
        '/manage-sales-account' : (context) => SalesAccountScreen(),       
      },
      debugShowCheckedModeBanner: false, 
    );
  }
}
