import 'dart:convert';
import 'add_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kodegiri/universal_screen/login_screen.dart';
import 'package:Kodegiri/admin_screens/edit_profile_screen.dart';
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  bool _viewArchived = false;

  String adminName = '';
  String adminEmail = '';
  String userToken = '';
  List _datalink = [];

  @override
  void initState() {
    _loadProfile();
    _getAllDataLinks();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('name') ?? 'tidak ada nama';
      adminEmail = prefs.getString('email') ?? 'tidak ada email';
      userToken = prefs.getString('token') ?? 'tidak ada token';
    });
  }

  Future<void> _getAllDataLinks() async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/links'),
        headers: {
          'Authorization': '$userToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status']) {
          final List<dynamic> links = data['response'];

          setState(() {
            _datalink = links;
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

  Future<void> _deletedLink(BuildContext context, int index) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/link/$index'),
        headers: {
          'Authorization': '$userToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await Future.delayed(const Duration(milliseconds: 500));

        if (data['status'] == true) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            onConfirmBtnTap: () {
              Navigator.pop(context);
            },
            confirmBtnColor: const Color(0xFF12C06A),
            customAsset: 'assets/gif/Success.gif',
            text: "Link Successfully Deleted!",
          );
        } else {
          print('Failed deleted : ${data['message']}');
          _showFeedback(context, 'Failed deleted : ${data['message']}');
        }
      } else {
        print('Error code : ${response.statusCode}');
        _showFeedback(context, 'Failed deleted : ${response.statusCode}');
      }
    } catch (e) {
      print('Erorr cant delete data : $e');
      _showFeedback(context, 'Erorr cant delete data : ${e}');
    }
  }

  void _confirmAndDeleteLink(int index, context) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: "Are You Sure Want to Delete This Link?",
      confirmBtnText: 'Delete',
      cancelBtnText: 'Cancel',
      confirmBtnColor: const Color(0xFF12C06A),
      onConfirmBtnTap: () async {
        Navigator.pop(context); 
        await _deletedLink(context, index); 
        await _getAllDataLinks(); 
      },
    );
  }

  void _logout() async {
    await SharedPreferencesHelper.removeData('name');
    await SharedPreferencesHelper.removeData('email');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          _viewArchived ? 'Archived Links' : 'Link Manager',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: Icon(_viewArchived ? Icons.view_list : Icons.archive),
            onPressed: () =>
                _showFeedback(context, 'Fitur ini masih dalam proses'),
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/kodegiri.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by title',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _datalink.length,
                    itemBuilder: (context, index) {
                      final link = _datalink[index];
                      final id = link['link_ID'];
                      return _buildCard(_datalink[index], id);
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _getAllDataLinks().then((result) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WebLauncherHomePage(),
                    ),
                  );
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    'assets/icons/UserProfile.png',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  adminName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Color(0xFF1F2937)),
            title: const Text('Manage Sales Accounts'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SalesAccountScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF1F2937)),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF1F2937)),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> linkData, int index) {
    return GestureDetector(
      onTap: () => _launchLink(linkData['url']!),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  linkData['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  linkData['url'] ?? 'No URL',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_viewArchived)
                    _buildIconButton(
                        Icons.unarchive,
                        Colors.green,
                        () => () => _showFeedback(
                            context, 'Fitur ini masih dalam proses'))
                  else
                    _buildIconButton(
                        Icons.archive,
                        Colors.orange,
                        () => () => _showFeedback(
                            context, 'Fitur ini masih dalam proses')),
                  _buildIconButton(
                      Icons.edit, Colors.blue, () => _editLink(index)),
                  _buildIconButton(Icons.delete, Colors.red,
                      () => _confirmAndDeleteLink(index, context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 27),
        ),
      ),
    );
  }

  Future<void> _editLink(int index) async {
    final linkData = _datalink.firstWhere(
        (element) => element['link_ID'] == index,
        orElse: () => null);

    if (linkData == null) {
      print('Link data not found for id: $index');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link data not found for id: $index')),
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          linkData: linkData,
          onSave: (updatedData) {
            final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
            setState(() async {
              try {
                final response = await http.patch(
                  Uri.parse('$apiUrl/link/$index'),
                  headers: {
                    'Authorization': '$userToken',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(updatedData),
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);

                  if (data['status'] == true) {
                    await Future.delayed(const Duration(milliseconds: 500));

                    await QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      onConfirmBtnTap: () {
                        Navigator.pop(context);
                      },
                      confirmBtnColor: const Color(0xFF12C06A),
                      customAsset: 'assets/gif/Success.gif',
                      text: "Link successfully updated!",
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to update: ${data['message']}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error code: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            });
          },
        ),
      ),
    );
  }
}

Future<void> _launchLink(String url) async {
  Uri uri;

  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    uri = Uri.parse('https://$url');
  } else {
    uri = Uri.parse(url);
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $uri';
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

class EditScreen extends StatelessWidget {
  final Map<String, dynamic> linkData;
  final Function(Map<String, String>) onSave;

  EditScreen({super.key, required this.linkData, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController =
        TextEditingController(text: linkData['title']);
    final TextEditingController _linkController =
        TextEditingController(text: linkData['url']);

    bool _isTitleValid = true;
    bool _isLinkValid = true;

    Future<void> _saveLink() async {
      if (_formKey.currentState!.validate()) {
        final updatedData = {
          'title': _titleController.text,
          'url': _linkController.text,
        };
        onSave(updatedData);
      }
    }

    String? _validateField(String value, String field) {
      if (value.isEmpty) {
        if (field == 'title') _isTitleValid = false;
        if (field == 'link') _isLinkValid = false;
        return '$field cannot be empty';
      }
      return null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        title: const Text('Edit Link'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Please fill out the form',
                style: TextStyle(fontSize: 16, color: Color(0xFF60605F)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F5F5F),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter the title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isTitleValid ? Colors.grey : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) => _validateField(value ?? '', 'Title'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Link',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F5F5F),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'Enter the Link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isLinkValid ? Colors.grey : Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) => _validateField(value ?? '', 'Link'),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 25, 47, 84),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(56, 56),
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
    );
  }
}
