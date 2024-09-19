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
  List<Map<String, String>> _links = [];
  List<Map<String, String>> _filteredLinks = [];
  List<Map<String, String>> _archivedLinks = [];
  TextEditingController _searchController = TextEditingController();
  bool _viewArchived = false;

  String adminName = '';
  String adminEmail = '';
  List _datalink = [];

  @override
  void initState() {
    super.initState();
    // _searchController.addListener(_filterLinks);
    // loadLinksFromSharedPreferences();
    _loadProfile();
    _getAllDataLinks();
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
    });
  }

  Future<void> _getAllDataLinks() async {
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX0lEIjoiOGQ5ZjRlNmItNTAyMi00YWY0LTljODQtNWM3OThkOGEyYjc4IiwibmFtZSI6IkFkbWluIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJpc0FkbWluIjp0cnVlLCJpYXQiOjE3MjY3MTk1MjN9.HWx1jEcPwIKXiSpTbyZuL6mcehtg8yYdMnPwqZp-e_g";
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/links',
        ),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      // print('response : ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status']) {
          // Extract the 'response' field from the decoded JSON
          final List<dynamic> links = data['response'];

          // Ensure that links are correctly processed
          setState(() {
            _datalink = links;
          });
          print('data : $links');
        } else {
          print('Failed to get links: ${data['message']}');
        }
      } else {
        print('Failed to get links: ${response.statusCode}');
      }
    } catch (e) {
      print('Erorr cant get data : $e');
    }
  }

  Future<void> _patchLink(int index, Map<String, String> updatedData) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully');
      } else {
        print('Failed to update data');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
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
            onPressed: _toggleViewArchived,
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
                      return _buildCard(_datalink[index], index);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebLauncherHomePage(),
                  ),
                ).then((result) {
                  _getAllDataLinks();
                  if (result != null) {
                    setState(() {
                     _links = List<Map<String, String>>.from(result);
                      // _filterLinks();
                    });
                  }
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
                    _buildIconButton(Icons.unarchive, Colors.green,
                        () => _unarchiveLink(index))
                  else
                    _buildIconButton(Icons.archive, Colors.orange,
                        () => _archiveLink(index)),
                  _buildIconButton(
                      Icons.edit, Colors.blue, () => _editLink(index)),
                  _buildIconButton(Icons.delete, Colors.red,
                      () => _confirmAndDeleteLink(index)),
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

  void _editLink(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          linkData: _datalink[index],
          onSave: (updatedData) {
            print('data edit :$updatedData');
            setState(() {
              // if (_viewArchived) {
              //   _archivedLinks[index] = updatedData;
              // } else {
              //   _links[index] = updatedData;
              // }
              // _filterLinks();
              // _saveLinksToSharedPreferences();
            });
          },
        ),
      ),
    );
  }
}

void _deleteLink(int index) async {
  // _datalink[index];
  
}






Future<void> loadLinksFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get all keys from SharedPreferences
  Set<String> keys = prefs.getKeys();

  List<Map<String, String>> loadedLinks = [];
  List<Map<String, String>> loadedArchivedLinks = [];

  // Loop through keys to find matching key (title_, link_, archived_)
  for (String key in keys) {
    if (key.startsWith('title_')) {
      String id = key.replaceFirst('title_', ''); // Extract ID from key
      String? title = prefs.getString('title_$id');
      String? link = prefs.getString('link_$id');
      bool? isArchived = prefs.getBool('archived_$id') ?? false;

      if (title != null && link != null) {
        if (isArchived) {
          loadedArchivedLinks.add({'title': title, 'link': link});
        } else {
          loadedLinks.add({'title': title, 'link': link});
        }
      }
    }
  }

  // setState(() {
  //   _links = loadedLinks;
  //   _archivedLinks = loadedArchivedLinks;
  //   _filterLinks();
  // });
}

Future<void> _saveLinksToSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Remove all previous data
  Set<String> keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('title_')) {
      String id = key.replaceFirst('title_', '');
      prefs.remove('title_$id');
      prefs.remove('link_$id');
      prefs.remove('archived_$id');
    }
  }

  // // Save the current links
  // for (int i = 0; i < _links.length; i++) {
  //   String id = _getIdFromLink(_links[i]['link']!);
  //   prefs.setString('title_$id', _links[i]['title']!);
  //   prefs.setString('link_$id', _links[i]['link']!);
  //   prefs.setBool('archived_$id', false);
  // }

  // for (int i = 0; i < _archivedLinks.length; i++) {
  //   String id = _getIdFromLink(_archivedLinks[i]['link']!);
  //   prefs.setString('title_$id', _archivedLinks[i]['title']!);
  //   prefs.setString('link_$id', _archivedLinks[i]['link']!);
  //   prefs.setBool('archived_$id', true);
  // }
}

void _archiveLink(int index) async {
  // Get the actual index of the link in the _links list based on the filtered list
  // Map<String, String> linkToArchive =
  //     _filteredLinks[index]; // Get the link data from the filtered list
  // int originalIndex = _links.indexWhere((link) =>
  //     link['link'] == linkToArchive['link']); // Find the index in _links

  // if (originalIndex < 0 || originalIndex >= _links.length) return;

  // String id = _getIdFromLink(_links[originalIndex]['link']!);

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('archived_$id', true);

  // setState(() {
  //   // Move the link to the archived list and remove from the main list
  //   _archivedLinks.add(_links[originalIndex]);
  //   _links.removeAt(originalIndex);
  //   _filterLinks(); // Refresh the filtered list
  // });

  await _saveLinksToSharedPreferences();

  _showFeedback('Link archived successfully');
}

void _unarchiveLink(int index) async {
  // // Get the actual index of the link in the _archivedLinks list based on the filtered list
  // Map<String, String> linkToUnarchive =
  //     _filteredLinks[index]; // Get the link data from the filtered list
  // int originalIndex = _archivedLinks.indexWhere((link) =>
  //     link['link'] ==
  //     linkToUnarchive['link']); // Find the index in _archivedLinks

  // if (originalIndex < 0 || originalIndex >= _archivedLinks.length) return;

  // String id = _getIdFromLink(_archivedLinks[originalIndex]['link']!);

  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setBool('archived_$id', false);

  // setState(() {
  //   // Move the link to the main list and remove from the archived list
  //   _links.add(_archivedLinks[originalIndex]);
  //   _archivedLinks.removeAt(originalIndex);
  //   _filterLinks(); // Refresh the filtered list
  // });

  await _saveLinksToSharedPreferences();
}

void _confirmAndDeleteLink(int index, context) async {
  final link = _links[index]; 

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
            onPressed: () async {
              Navigator.pop(context);
              final response = await http.delete(
                Uri.parse('http://localhost:3000/api/link/${link}'),
                headers: {'Content-Type': 'application/json'},
              );
              if (response.statusCode == 200) {
                // _getAllDataLinks();
              } else {
                print('Failed to delete link');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


void _toggleViewArchived() {
  // setState(() {
  //   _viewArchived = !_viewArchived;
  //   _filterLinks();
  // });
}

// void _filterLinks() {
//   String searchTerm = _searchController.text.toLowerCase();
//   setState(() {
//     if (_viewArchived) {
//       _filteredLinks = _archivedLinks
//           .where((link) =>
//               link['title']!.toLowerCase().contains(searchTerm) ||
//               link['url']!.toLowerCase().contains(searchTerm))
//           .toList();
//     } else {
//       _filteredLinks = _links
//           .where((link) =>
//               link['title']!.toLowerCase().contains(searchTerm) ||
//               link['url']!.toLowerCase().contains(searchTerm))
//           .toList();
//     }
//   });
// }

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

String _getIdFromLink(String link) {
  return link;
}

void _showFeedback(String message) {
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     content: Text(message),
  //     duration: const Duration(seconds: 2),
  //   ),
  // );
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
                  'link': linkController.text,
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
