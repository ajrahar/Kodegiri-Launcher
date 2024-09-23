import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';
import 'package:Kodegiri/admin_screens/home_screen.dart';
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
  String token = '';

  bool _isTitleValid = true;
  bool _isLinkValid = true;

  void _saveLink() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final url = _linkController.text;
      token =
          await SharedPreferencesHelper.getString('token') ?? 'token tidak ada';
      final Map<String, dynamic> linkData = {
        "user_ID": null,
        "title": title,
        "url": url
      };

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
          final data = jsonDecode(response.body);

          if (data['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Link created : ${data['message']} ')),
            );
            print('Link created : ${data['message']}');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Link Gagal ditambahkan ${data['message']}')),
            );
            print('Link Gagal ditambahkan : ${data['message']}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error satatus code ${response.statusCode}')),
          );
          print('Failed to get links: ${response.statusCode}');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link Gagal ditambahkan ${error}')),
        );
        print('Terjadi kesalahan: $error');
      }
    }
  }

  String? _validateField(String value, String field) {
    if (value.isEmpty) {
      setState(() {
        if (field == 'title') _isTitleValid = false;
        if (field == 'link') _isLinkValid = false;
      });
      return '$field should not be empty';
    }
    setState(() {
      if (field == 'title') _isTitleValid = true;
      if (field == 'link') _isLinkValid = true;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 47, 84),
        foregroundColor: Colors.white,
        title: const Text('Add New Link'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                validator: (value) => _validateField(value ?? '', 'name'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Link',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'Enter Link',
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 25, 47, 84),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
  String id =
      List.generate(6, (index) => chars[random.nextInt(chars.length)]).join('');

  return id;
}
