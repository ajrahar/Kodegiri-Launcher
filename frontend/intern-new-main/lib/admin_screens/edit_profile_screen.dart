import 'package:flutter/material.dart';
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:Kodegiri/admin_screens/home_screen.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:Kodegiri/universal_screen/all-alert.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _obscurePassword = true;
  String userToken = '';
  String user_ID = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _loadProfile() async {
    userToken =
        await SharedPreferencesHelper.getString('token') ?? 'tidak ada token';
    user_ID = await SharedPreferencesHelper.getString('user_ID') ??
        'tidak ada user_ID';
    if (user_ID.isNotEmpty) {
      await _getAccount(context);
    } else {
      await CustomAlert.showFailedAlert(
        context,
        "user_ID tidak ada",
      );
    }
  }

  Future<void> _getAccount(BuildContext context) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/${user_ID}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            _nameController.text = data['response']['name'] ?? '';
            _emailController.text = data['response']['email'] ?? '';
          });
        } else {
          print('Failed to get links : ${data['message']}');
          _showFeedback(context, 'Failed to get links : ${data['message']}');
        }
      } else {
        Future.delayed(const Duration(milliseconds: 500));
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Failed",
          confirmBtnColor: const Color(0xFFde0239),
          text: "Failed to Get Data Sales Account",
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      print('Erorr cant get data : $e');
      _showFeedback(context, 'Erorr cant get data : ${e}');
    }
  }

  Future<void> _saveAccount() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    if (_formKey.currentState!.validate()) {
      final userId = user_ID;
      final updatedAccount = {
        'name': _nameController.text.isNotEmpty ? _nameController.text : '',
        'email': _emailController.text.isNotEmpty ? _emailController.text : '',
        'password':
            _passwordController.text.isNotEmpty ? _passwordController.text : '',
      };

      try {
        final response = await http.patch(
          Uri.parse('$apiUrl/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updatedAccount),
        );
        var responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          await CustomAlert.showSuccessAlert(
            context,
            responseData["message"] ??
                "Congratulations, Sales account successfully updated!",
            onConfirmBtnTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          );
        } else {
          await CustomAlert.showFailedAlert(
            context,
            responseData["message"] ?? "Failed to Update Sales Account",
          );
        }
      } catch (e) {
        await CustomAlert.showFailedAlert(
          context,
          '$e',
        );
      }
    }
  }

  String? _validateFullName(String? value) {
    return value == null || value.isEmpty ? 'Full name cannot be empty' : null;
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

  String? _validatePassword(String value) {
    RegExp regex = RegExp(r'^.{8,}$');
    if (value.isEmpty) {
      return null;
    } else {
      if (!regex.hasMatch(value)) {
        return 'Please enter password with at least 8 characters';
      } else {
        return null;
      }
    }
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF9F9F9),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isNameValid ? Colors.grey : Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  validator: (value) => _validateFullName(value ?? ''),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isEmailValid ? Colors.grey : Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  validator: (value) => _validateEmail(value ?? ''),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isPasswordValid ? Colors.grey : Colors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
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
                  validator: (value) => _validatePassword(value ?? ''),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 25, 47, 84),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 18)),
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
