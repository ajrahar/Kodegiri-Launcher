import 'package:flutter/foundation.dart';

class LinkProvider with ChangeNotifier {  
  List<Map<String, String>> _links = [];

  List<Map<String, String>> get links => _links;

  void addLink(Map<String, String> link) {
    _links.add(link);
    notifyListeners();
  }
 
}
