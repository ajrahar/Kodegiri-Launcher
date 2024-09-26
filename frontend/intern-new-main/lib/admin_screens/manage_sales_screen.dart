import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';
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
  }

  Future<void> _getAllDataAccount() async {
     final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    try {
      final response = await http.get(
         Uri.parse('$apiUrl/users/'),
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
          final List<dynamic> dataAccountList = data['response'];

          setState(() {
            _dataAccounts = dataAccountList
                .map((account) => account as Map<String, dynamic>)
                .toList();
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
    var userID = _dataAccounts[index]['user_ID'];   
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSalesAccountScreen(
          user_ID :userID,
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

Future<void> _deletedAccount(BuildContext context, int index) async {
  final userId = _dataAccounts[index]['user_ID']; 
  final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';      

  try {
    final response = await http.delete(     
      Uri.parse('$apiUrl/user/$userId'),
      headers: {
        'Authorization': '$userToken', 
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        print('Deleted Account: ${data['message']}');
        _showFeedback(context, 'Deleted link: ${data['message']}');
        _getAllDataAccount();
      } else {
        print('Failed to delete: ${data['message']}');
        _showFeedback(context, 'Failed to delete: ${data['message']}');
      }
    } else {
      print('Error code: ${response.statusCode}');
      _showFeedback(context, 'Failed to delete: ${response.statusCode}');
    }
  } catch (e) {
    print('Error while deleting data: $e');
    _showFeedback(context, 'Error while deleting data: $e');
  }
}


  void _confirmAndDeleteAccount(int index, context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this account'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {
              _deletedAccount(context, index),
              Navigator.pop(context),
              _getAllDataAccount()
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                            _confirmAndDeleteAccount(index, context);
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
                              onTap: () =>
                                  _confirmAndDeleteAccount(index, context),
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
