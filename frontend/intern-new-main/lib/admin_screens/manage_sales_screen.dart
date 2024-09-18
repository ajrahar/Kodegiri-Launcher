import 'package:flutter/material.dart';
import 'package:Kodegiri/user_screens/add_sales_account_screen.dart';
import 'package:Kodegiri/user_screens/edit_sales_account_screen.dart';

class SalesAccountScreen extends StatefulWidget {
  const SalesAccountScreen({super.key});

  @override
  State<SalesAccountScreen> createState() => _SalesAccountScreenState();
}

class _SalesAccountScreenState extends State<SalesAccountScreen> {
  List<Map<String, String>> _accounts = []; // Data akun sales marketing

  @override
  void initState() {
    super.initState();
    _loadAccounts(); // Load data akun dari sumber data
  }

  void _loadAccounts() {
    // Fungsi untuk memuat data akun dari penyimpanan lokal atau server
    setState(() {
      _accounts = [
        {'name': 'John Doe', 'email': 'john@example.com', 'password': '123456'},
        {
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'password': 'abcdef'
        },
      ];
    });
  }

  void _addAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSalesAccountScreen(),
      ),
    ).then((newAccount) {
      if (newAccount != null) {
        setState(() {
          _accounts.add(newAccount);
        });
      }
    });
  }

  void _editAccount(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSalesAccountScreen(
          account: _accounts[index],
          onSave: (updatedAccount) {
            setState(() {
              _accounts[index] = updatedAccount;
            });
          },
        ),
      ),
    );
  }

  void _deleteAccount(int index) {
    setState(() {
      _accounts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sales Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_accounts[index]['name']!),
            subtitle: Text(_accounts[index]['email']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editAccount(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAccount(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        child: const Icon(Icons.add),
      ),
    );
  }
}
