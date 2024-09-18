import 'package:flutter/material.dart';

class AddSalesAccountScreen extends StatefulWidget {
  const AddSalesAccountScreen({super.key});

  @override
  State<AddSalesAccountScreen> createState() => _AddSalesAccountScreenState();
}

class _AddSalesAccountScreenState extends State<AddSalesAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _saveAccount() {
    final newAccount = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    Navigator.pop(context, newAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sales Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAccount,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
