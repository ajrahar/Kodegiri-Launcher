import 'package:flutter/material.dart';
import 'admin_screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'universal_screen/login_screen.dart';
import 'universal_screen/splash_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/universal_screen/link_provider.dart'; 
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';

void main() async{
   await dotenv.load(fileName: "assets/.env");
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
