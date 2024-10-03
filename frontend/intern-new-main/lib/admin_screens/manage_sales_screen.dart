import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
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
    super.initState();
  }

  Future<void> _loadProfile() async {
    userToken = await SharedPreferencesHelper.getString('token') ?? 'tidak ada token';
    if (userToken.isNotEmpty) { 
      await _getAllDataAccount();
    } else {
      _showFeedback(context, 'Token is empty, cannot fetch data');
    }
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
    
    var responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200 && responseData['status']) {
      final List<dynamic> dataAccountList = responseData['response'];
      setState(() {
        _dataAccounts = dataAccountList
            .map((account) => account as Map<String, dynamic>)
            .toList();
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: responseData['message'] ?? 'Failed to get account data!',
        confirmBtnColor: const Color(0xFFde0239),
        onConfirmBtnTap: () {
          Navigator.pop(context);
        }
      );
    }
  } catch (e) {
    print('Error cant get data : $e');
    _showFeedback(context, 'Error cant get data : $e');
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
          user_ID: userID,
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
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          await Future.delayed(const Duration(milliseconds: 500));

          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: "Success",
            confirmBtnColor: const Color(0xFF12C06A),
            text: responseData['message'] ?? "Deleted Account",
            onConfirmBtnTap: () {
              Navigator.pop(context);
              _getAllDataAccount();
            },
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 500));

          await QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "Failed",
            confirmBtnColor: const Color(0xFFde0239),
            text: responseData['message'] ?? "Failed to Delete Sales Account",
            onConfirmBtnTap: () {
              Navigator.pop(context);
            },
          );
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
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: "Are You Sure Want to Delete This Account?",
      confirmBtnText: 'Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: const Color(0xFF12C06A),
      onConfirmBtnTap: () async {
        Navigator.pop(context);
        await _deletedAccount(context, index);
        await _getAllDataAccount();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        centerTitle: true,
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
                      leading: Image.asset(
                        'assets/icons/UserProfile.png',
                        width: 40,
                        height: 40,
                      ),
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
