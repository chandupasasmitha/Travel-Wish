import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://10.0.2.2:2000/api/";

  static adduser(Map udata) async {
    print(udata);
    var url = Uri.parse("${baseUrl}add_data");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"}, // ADD HEADER
        body: jsonEncode(udata), // CONVERT TO JSON
      );

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

  static Future<bool> loginUser(Map loginData) async {
    var url = Uri.parse("${baseUrl}login");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      var data = jsonDecode(res.body.toString());

      if (res.statusCode == 200 && data['message'] == "Login successful") {
        print("Login Success: $data");
        return true;
      } else {
        print("Login Failed: ${res.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }
}
