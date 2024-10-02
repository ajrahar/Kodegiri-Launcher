import 'package:flutter/material.dart';
import 'admin_screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'universal_screen/login_screen.dart';
import 'universal_screen/splash_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/universal_screen/link_provider.dart'; 
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
      home: AuthCheck(), 
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(), 
        '/manage-sales-account' : (context) => SalesAccountScreen(),       
      },
      debugShowCheckedModeBanner: false, 
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  String? userToken;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async { 
    String? token = await SharedPreferencesHelper.getString('token');

    setState(() {
      userToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userToken == null) {      
      return SplashScreen(); 
    } else if (userToken!.isNotEmpty) {
      return HomeScreen();
    } else {    
      return LoginScreen();
    }
  }
}
