import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../Models/LinkModel.dart';
import 'package:http/http.dart' as http;

class ClubService {
  static Future<List<CategoryModel>> getLinks() async {
    final List<CategoryModel> list = [];
    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
          Uri.parse('https://link.xauat.site/api/Link/GetCategory'),
          headers: finalHeaders);


      if (response.statusCode == 200) {
        for (var item in jsonDecode(response.body)) {
          list.add(CategoryModel.fromJson(item));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }
}
