import 'dart:convert';
import 'package:Kodegiri/universal_screen/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kodegiri/user_screens/add_sales_account_screen.dart';
import 'package:Kodegiri/user_screens/edit_sales_account_screen.dart';

void _showFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

class SalesAccountScreen extends StatefulWidget {
  const SalesAccountScreen({super.key});

  @override
  State<SalesAccountScreen> createState() => _SalesAccountScreenState();
}

class _SalesAccountScreenState extends State<SalesAccountScreen> {
  List<Map<String, dynamic>> _dataAccounts = [];

  String userToken = '';

  @override
  void initState() {
    _loadProfile();
    _getAllDataAccount();
    super.initState();
  }

  Future<void> _loadProfile() async {
    setState(() async {
      userToken =
          await SharedPreferencesHelper.getString('token') ?? 'token tidak ada';
    });
    // setState(() {
    //   userToken = prefs.getString('token') ?? 'tidak ada token';
    // });
  }

  Future<void> _getAllDataAccount() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/users',
        ),
        headers: {
          'Authorization': '$userToken',
          'Content-Type': 'application/json',
        },
      );
      print('$userToken');
      print('${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status']) {
          final List<Map<String, dynamic>> dataAccountList = data['response'];

          setState(() {
            _dataAccounts = dataAccountList;
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

  void _addAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSalesAccountScreen(),
      ),
    ).then((newAccount) {
      if (newAccount != null) {
        setState(() {
          _dataAccounts.add(newAccount);
        });
      }
    });
  }

  void _editAccount(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSalesAccountScreen(
          account: _dataAccounts[index],
          onSave: (updatedAccount) {
            setState(() {
              _dataAccounts[index] = updatedAccount;
            });
          },
        ),
      ),
    );
  }

  void _deleteAccount(int index) {
    setState(() {
      _dataAccounts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        title: const Text('Manage Sales Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _dataAccounts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    color: const Color(0xFFF9F9F9),
                    elevation: 0,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.account_circle,
                          size: 40, color: Colors.blue),
                      title: Text(
                        _dataAccounts[index]['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_dataAccounts[index]['email']!),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        color: const Color(0xFFF9F9F9),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editAccount(index);
                          } else if (value == 'delete') {
                            _deleteAccount(index);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit,
                                  color: const Color.fromARGB(255, 25, 47, 84)),
                              title: const Text('Edit',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            textStyle: const TextStyle(color: Colors.black),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete,
                                  color: const Color.fromARGB(255, 25, 47, 84)),
                              title: const Text('Delete',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            textStyle: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 47, 84),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Sales Account',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
