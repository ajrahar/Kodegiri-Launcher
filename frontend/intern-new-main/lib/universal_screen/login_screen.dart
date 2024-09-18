import 'package:flutter/material.dart';
import 'package:Kodegiri/admin_screens/home_screen.dart'; // Ensure you have this file and it is properly set up
import 'package:Kodegiri/user_screens/uhome_screen.dart'; // Ensure you h 
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List _datauser = [];

  // Future<void> postDataUser() async {
  //   try {
  //     final response = await http.post(Uri.parse('http://localhost:3000/api/user/auth/login', ), body: {
  //       'username': _usernameController.text,
  //       'password': _passwordController.text,
  //     });
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // print('Data users: $data');
  //       setState(() {
  //         _datauser = data;
  //         // print('Data user berhasil diperbarui: $_datauser');
  //       });
  //     } else if (response.statusCode == 404) {
  //       final message = jsonDecode(response.body)['message'];
  //       print('Error: $message'); // Error: Tidak ada data user ditemukan
  //     } else {
  //       final message = jsonDecode(response.body)['message'];
  //       print('Error: $message'); // Error: Data user gagal ditemukan
  //     }
  //   } catch (e) {
  //     print('Cannot get data. Error : $e');
  //   }
  // }

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    // TODO: implement initState 
    super.initState();
    // _saveEmailToSharedPreferences(email.text);
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _sweatAlert(BuildContext context, bool isAdmin) {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Login berhasil",
      desc: "Selamat anda berhasil login",
      buttons: [
        DialogButton(
            child: Text(
              "Selanjutnya",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Menutup dialog
              // Optionally, you can navigate based on admin role
              if (isAdmin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SalesScreen()),
                );
              }
            })
      ],
    ).show();
    return;
  }

  void _login() async {
    final email = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
          Uri.parse(
            'http://localhost:3000/api/user/auth/login',
          ),
          body: {'email': email, 'password': password});

      var responseData = jsonDecode(response.body);

      if (responseData['status'] == true) {
        String token = responseData['token'];
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        bool isAdmin = decodedToken['isAdmin'] == true;

        _sweatAlert(context, isAdmin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed : ${responseData['message']}')),
        );
      }
    } catch (e) {
      print('Cannot get data. Error : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot get data. Error : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('data user : \n');
    print(_datauser);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[800]!, Colors.blueGrey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/kodegiri.png', height: 100),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 35, 61, 105)),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 23, 37, 61)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                            color: const Color.fromARGB(255, 25, 47, 84),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 29, 44, 69),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
