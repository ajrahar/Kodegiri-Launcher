import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:quickalert/quickalert.dart';

class AddSalesAccountScreen extends StatefulWidget {
  const AddSalesAccountScreen({super.key});

  @override
  State<AddSalesAccountScreen> createState() => _AddSalesAccountScreenState();
}

class _AddSalesAccountScreenState extends State<AddSalesAccountScreen> {
  final List<Map<String, String>> _userData = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _saveAccount() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    if (_formKey.currentState!.validate()) {
      final newAccount = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/user'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newAccount),
        );

        if (response.statusCode == 201) {
          Future.delayed(const Duration(milliseconds: 500));
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            confirmBtnColor: const Color(0xFF12C06A),
            customAsset: 'assets/gif/Success.gif',
            text: "Congratulations, Sales account successfully created!",
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SalesAccountScreen()),
              );
            },
          );
        } else {
          Future.delayed(const Duration(milliseconds: 500));
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Failed",
            confirmBtnColor: const Color(0xFFde0239),
            text: "Failed to Add Sales Account",
            onConfirmBtnTap: () {
              Navigator.of(context).pop();
            },
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  String? _validateField(String value, String field) {
    if (value.isEmpty) {
      setState(() {
        if (field == 'name') _isNameValid = false;
        if (field == 'email') _isEmailValid = false;
        if (field == 'password') _isPasswordValid = false;
      });
      return '$field should not be empty';
    }
    setState(() {
      if (field == 'name') _isNameValid = true;
      if (field == 'email') _isEmailValid = true;
      if (field == 'password') _isPasswordValid = true;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Add Sales Account'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SalesAccountScreen()));
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
                  validator: (value) => _validateField(value ?? '', 'Name'),
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
                  validator: (value) => _validateField(value ?? '', 'Email'),
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
                  validator: (value) => _validateField(value ?? '', 'Password'),
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
