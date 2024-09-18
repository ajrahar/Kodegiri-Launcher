import 'package:flutter/foundation.dart';

class LinkProvider with ChangeNotifier {
  // Define your LinkProvider class here
  List<Map<String, String>> _links = [];

  List<Map<String, String>> get links => _links;

  void addLink(Map<String, String> link) {
    _links.add(link);
    notifyListeners();
  }

  // Add other methods as needed
}
