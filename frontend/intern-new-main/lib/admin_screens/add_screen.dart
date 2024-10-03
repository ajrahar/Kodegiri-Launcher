import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Kodegiri/admin_screens/home_screen.dart';
import 'package:Kodegiri/universal_screen/shared_preference.dart';

class WebLauncherHomePage extends StatefulWidget {
  const WebLauncherHomePage({super.key});

  @override
  _WebLauncherHomePageState createState() => _WebLauncherHomePageState();
}

class _WebLauncherHomePageState extends State<WebLauncherHomePage> {
  // final List<Map<String, String>> _links = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String token = '';

  bool _isTitleValid = true;
  bool _isLinkValid = true;

  void _saveLink() async {
     final apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';      
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
           Uri.parse('$apiUrl/links'),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(linkData),
        );
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);

          if (data['status'] == true) {
            print('Link created : ${data['message']}');

            await Future.delayed(const Duration(milliseconds: 500));
            
            await QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: "Success",
              confirmBtnColor: const Color(0xFF12C06A),  
              customAsset: 'assets/gif/Success.gif', 
              text: "Link Successfully Created!",
              onConfirmBtnTap: () {
                Navigator.pop(context);
              },              
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            Future.delayed(const Duration(milliseconds: 500)); 
           QuickAlert.show(context: context, type: QuickAlertType.error,
           title: "Failed",
           confirmBtnColor: const Color(0xFFde0239),
           text: "Failed to Add Link",
           onConfirmBtnTap: () {
             Navigator.of(context).pop();
           },
            );
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //       content: Text('Link Gagal ditambahkan ${data['message']}')),
            // );
            // print('Link Gagal ditambahkan : ${data['message']}');
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
      return '$field cannot be empty';
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
        centerTitle: true,
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
              const SizedBox(height: 16),
              const Text(
                'Please fill out the form',
                style: TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 96, 95, 95)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 95, 95, 95),
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
                  color: Color.fromARGB(255, 95, 95, 95),
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
