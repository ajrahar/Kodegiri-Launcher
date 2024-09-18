import 'package:flutter/material.dart';

class EditSalesAccountScreen extends StatefulWidget {
  final Map<String, String> account;
  final Function(Map<String, String>) onSave;

  const EditSalesAccountScreen(
      {super.key, required this.account, required this.onSave});

  @override
  State<EditSalesAccountScreen> createState() => _EditSalesAccountScreenState();
}

class _EditSalesAccountScreenState extends State<EditSalesAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account['name']);
    _emailController = TextEditingController(text: widget.account['email']);
    _passwordController =
        TextEditingController(text: widget.account['password']);
  }

  void _saveAccount() {
    final updatedAccount = {
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    widget.onSave(updatedAccount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sales Account'),
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
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
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
