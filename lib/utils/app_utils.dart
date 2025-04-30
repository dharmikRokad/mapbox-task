import 'dart:convert';

import 'package:flutter/services.dart';

class AppUtils {
  static Future<Map<String, dynamic>> fetchJsonFromAsset(String path) async {
    final String json = await rootBundle.loadString(path);

    final Map<String, dynamic> map = jsonDecode(json);

    return map;
  }
}
