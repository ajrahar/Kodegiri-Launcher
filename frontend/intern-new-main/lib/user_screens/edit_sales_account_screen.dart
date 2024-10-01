import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';

void _showFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

class EditSalesAccountScreen extends StatefulWidget {
  final String user_ID;
  final Map<String, dynamic> account;
  final Function(Map<String, dynamic>) onSave;

  const EditSalesAccountScreen(
      {super.key,required this.user_ID, required this.account, required this.onSave});

  @override
  State<EditSalesAccountScreen> createState() => _EditSalesAccountScreenState();
}

class _EditSalesAccountScreenState extends State<EditSalesAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    _getAccount(context);
    super.initState();
  }

  Future<void> _getAccount(BuildContext context) async { 
     final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000'; 
    try {
      final response = await http.get(
          Uri.parse('$apiUrl/user/${widget.user_ID}'),       
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            _nameController.text = data['response']['name'];
            _emailController.text = data['response']['email'];           
          });
        } else {
          print('Failed to get links : ${data['message']}');
          _showFeedback(context, 'Failed to get links : ${data['message']}');
        }
      } else {
        print('Failed to get links : ${response.statusCode}');
        _showFeedback(context, 'Failed to get links : ${response.statusCode}');
      }
    } catch (e) {
      print('Erorr cant get data : $e');
      _showFeedback(context, 'Erorr cant get data : ${e}');
    }
  }

  Future<void> _saveAccount() async {
      final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';    
    if (_formKey.currentState!.validate()) {
      final userId = widget.account['user_ID'];
      final updatedAccount = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await http.patch(
            Uri.parse('$apiUrl/user/$userId'),       
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updatedAccount),
        );

        if (response.statusCode == 200) {
          _showFeedback(context, 'Account updated successfully');
          widget.onSave(updatedAccount);
          Navigator.pop(context);
        } else {
          _showFeedback(
              context, 'Failed to update account: ${response.statusCode}');
        }
      } catch (e) {
        _showFeedback(context, 'Error updating account: $e');
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
      backgroundColor: const Color(0XFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        title: const Text('Edit Profile'),
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
                  obscureText: true,
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
