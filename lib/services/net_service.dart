import 'dart:convert';

import 'package:http/http.dart' as http;

class NetService {
  static Future<Map<String, dynamic>> get() async {
    var response = await http.get(
        Uri.parse('http://10.99.144.34/cgi-bin/rad_user_info?callback=json'));
    if (response.statusCode == 200) {
      var text = response.body;
      text = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
      final res = jsonDecode(text);
      return res;
    } else {
      throw Exception('Failed to load post');
    }
  }
}
