import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

class WebLauncherHomePage extends StatefulWidget {
  const WebLauncherHomePage({super.key});

  @override
  _WebLauncherHomePageState createState() => _WebLauncherHomePageState();
}

class _WebLauncherHomePageState extends State<WebLauncherHomePage> {
  final List<Map<String, String>> _links = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  int? _editingIndex;

  void _saveLink() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text; 
      final url = _linkController.text;
      String token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX0lEIjoiOGQ5ZjRlNmItNTAyMi00YWY0LTljODQtNWM3OThkOGEyYjc4IiwibmFtZSI6IkFkbWluIiwiZW1haWwiOiJhZG1pbkBnbWFpbC5jb20iLCJpc0FkbWluIjp0cnVlLCJpYXQiOjE3MjY3MTk1MjN9.HWx1jEcPwIKXiSpTbyZuL6mcehtg8yYdMnPwqZp-e_g";

      final Map<String, dynamic> linkData = {"title": title, "url": url};

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/links'),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(linkData),
        );
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Link Berhasil ditambahkan')),
          );
          
         Navigator.pop(context, _links);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Link Gagal ditambahkan')),
          );
        }
      } catch (error) {
        print('Terjadi kesalahan: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Link',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A),
        leading: _editingIndex != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _cancelEdit,
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(labelText: 'Link'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a link';
                      } else if (!value.contains('.')) {
                        return 'Please enter a valid link with a "."';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveLink,
                    child: Text(
                        _editingIndex == null ? 'Add Link' : 'Update Link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _links.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_links[index]['title']!),
                    subtitle: Text(_links[index]['link']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editLink(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteLink(index),
                        ),
                      ],
                    ),
                    onTap: () => _launchLink(_links[index]['link']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editLink(int index) {
    setState(() {
      _titleController.text = _links[index]['title']!;
      _linkController.text = _links[index]['link']!;
      _editingIndex = index;
    });
  }

  void _deleteLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

  Future<void> _launchLink(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _titleController.clear();
      _linkController.clear();
    });
  }

  Future<void> _saveTitleToSharedPreferences(
      String id, String title, String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Menyimpan title dan link dengan key unik
    await prefs.setString('title_$id', title);
    await prefs.setString('link_$id', link);
  }

  String generateUniqueId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    // Generate a 6-character string from the chars list
    String id = List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join('');

    return id;
  }
}
