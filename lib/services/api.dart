import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://192.168.147.219/api/";

  static adduser(Map udata) async {
    print(udata);
    var url = Uri.parse("${baseUrl}add_data");

    try {
      final res = await http.post(url, body: udata);

      if (res.statusCode == 200) {
        var data1 = jsonDecode(res.body.toString());
        print(data1);
      } else {
        throw Exception("Failed to add user");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static getuser() async {
    var url = Uri.parse("${baseUrl}get_data");
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        var data1 = jsonDecode(res.body.toString());
        print(data1);
      } else {
        throw Exception("Failed to get user");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
