import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/user_screens/uhome_screen.dart';
import 'package:Kodegiri/admin_screens/home_screen.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _sweatAlert(BuildContext context, bool isAdmin) {
    Future.delayed(const Duration(milliseconds: 500), () {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Login Successful",
        confirmBtnColor: const Color(0xFF12C06A),
        customAsset: 'assets/gif/Success.gif',
        text: "Congratulations, you have successfully logged in!",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();

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
        },
      );
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty'; // Cek jika input kosong
    }
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email'; // Cek format input dengan regex
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty'; // Cek jika input kosong
    }
    return null;
  }

  void _login() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    if (_formKey.currentState!.validate()) {
      final email = _usernameController.text;
      final password = _passwordController.text;

      try {
        final response = await http.post(Uri.parse('$apiUrl/user/auth/login'),
            body: {'email': email, 'password': password});

        var responseData = jsonDecode(response.body);
        if (responseData['status']) {
          String token = responseData['token'];
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          bool isAdmin = decodedToken['isAdmin'] == true;

          await SharedPreferencesHelper.saveString(
              'user_ID', decodedToken['user_ID']);
          await SharedPreferencesHelper.saveToken(token);
          _sweatAlert(context, isAdmin);
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Login Failed",
            confirmBtnColor: const Color(0xFFde0239),
            customAsset: 'assets/gif/Failed.gif',
            text: responseData['message'] ?? "Login failed",
            onConfirmBtnTap: () {
              Navigator.pop(context);
            },
          );
        }
      } catch (e) {
        print('Cannot get data. Error : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot get data. Error : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: Form(
              key: _formKey,
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
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Enter email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isEmailValid ? Colors.grey : Colors.red,
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 35, 61, 105)),
                            suffixIcon: Icon(
                              Icons.email,
                              color: const Color.fromARGB(255, 25, 47, 84),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (value) => _validateEmail(value ?? ''),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _isEmailValid ? Colors.grey : Colors.red,
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 35, 61, 105)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordVisibility,
                              color: const Color.fromARGB(255, 25, 47, 84),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (value) => _validatePassword(value ?? ''),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: Text('Login',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 29, 44, 69),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
      ),
    );
  }
}
