import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:url_launcher/url_launcher.dart';
import 'package:Kodegiri/universal_screen/link_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:Kodegiri/universal_screen/shared_preference.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List _datalink = [];
  String userToken = '';

  @override
  void initState() {
    _loadProfileAndGetData();
    super.initState();
    // You can initialize or fetch data here if needed
  }
    Future<void> _loadProfileAndGetData() async {
    // Tunggu hingga profile dimuat terlebih dahulu
    await _loadProfile();

    // Setelah token di-load, baru lanjutkan dengan mengambil data link
    if (userToken.isNotEmpty) {
      _getAllDataLinks();
    } else {
      print('Token is empty, cannot fetch data');
    }
  }

  Future<void> _loadProfile() async {
    // setState(() async { 
    userToken =
        await SharedPreferencesHelper.getString('token') ?? 'tidak ada token';
    // });
  }

  Future<void> _getAllDataLinks() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/links',
        ),
        headers: {
          HttpHeaders.authorizationHeader: '$userToken',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );
      // print('response : ${response.body}');
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

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    // Access the LinkProvider
    final linkProvider = Provider.of<LinkProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Link Manager',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Log Out',
          ),
        ],
      ),
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
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: linkProvider.links.length,
                    itemBuilder: (context, index) {
                      return _buildCard(linkProvider.links[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, String> linkData) {
    return GestureDetector(
      onTap: () => _launchLink(linkData['link']!),
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
                  linkData['title']!,
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
                  linkData['link']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}