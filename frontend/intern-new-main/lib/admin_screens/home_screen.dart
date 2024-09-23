import 'package:Kodegiri/admin_screens/edit_profile_screen.dart';
import 'package:Kodegiri/admin_screens/manage_sales_screen.dart';
import 'package:Kodegiri/universal_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    // _searchController.addListener(_filterLinks);
  }

  @override
  void dispose() {
    // _searchController.removeListener(_filterLinks);
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
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/links',
        ),
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
          // print('data : $links');
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
    try {
      final response = await http.delete(
        Uri.parse(
          'http://localhost:3000/api/link/$index',
        ),
        headers: {
          'Authorization': '$userToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          print('Deleted link: ${data['message']}');
          _showFeedback(context, 'Deleted link: ${data['message']}');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this link?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {
              _deletedLink(context, index),
              Navigator.pop(context),
              _getAllDataLinks()
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: Icon(_viewArchived ? Icons.view_list : Icons.archive),
            onPressed: () =>
                _showFeedback(context, 'Fitur ini masih dalam proses'),
          ),
        ],
      ),
      drawer: _buildSidebar(), // Include the sidebar (Drawer)
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

  // Sidebar (Drawer) implementation
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
                    'assets/images/profile.png', // Add your admin profile image
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  adminName, // Update with current admin name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  adminEmail, // Update with current admin email
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: Colors.black),
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
            leading: const Icon(Icons.edit, color: Colors.black),
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
            leading: const Icon(Icons.logout, color: Colors.black),
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
            // print('data edit :$updatedData');
            setState(() async {
              try {
                final response = await http.patch(
                  Uri.parse('http://localhost:3000/api/link/$index'),
                  headers: {
                    'Authorization': '$userToken',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(updatedData), // Data yang ingin diupdate
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);

                  if (data['status'] == true) {
                    // print('Updated link : ${data['message']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Updated link: ${data['message']}')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    // print('Failed to update: ${data['message']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to update: ${data['message']}')),
                    );
                  }
                } else {
                  // print('Error code: ${response.statusCode}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error code: ${response.statusCode}')),
                  );
                }
              } catch (e) {
                // print('Error: cannot update data: $e');
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
    await launchUrl(uri);
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

  const EditScreen({super.key, required this.linkData, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: linkData['title']);
    final TextEditingController linkController =
        TextEditingController(text: linkData['url']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: 'Link'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onSave({
                  'title': titleController.text,
                  'url': linkController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
