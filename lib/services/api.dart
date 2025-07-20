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

  // New method to fetch accommodations
  static Future<List<Map<String, dynamic>>> getAccommodations() async {
    var url = Uri.parse("${baseUrl}accommodations");
    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);

        // Handle your API response format
        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

        // Fallback for other formats
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to fetch accommodations: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching accommodations: $e");
      throw Exception("Failed to fetch accommodations: $e");
    }
  }

  // Method to fetch accommodation details by ID
  static Future<Map<String, dynamic>> getAccommodationById(String id) async {
    var url = Uri.parse("${baseUrl}accommodations/$id");
    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);

        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          return Map<String, dynamic>.from(responseData['data']);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
            "Failed to fetch accommodation details: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching accommodation details: $e");
      throw Exception("Failed to fetch accommodation details: $e");
    }
  }

  // Method to search accommodations
  static Future<List<Map<String, dynamic>>> searchAccommodations({
    String? query,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    String? propertyType,
  }) async {
    var url = Uri.parse("${baseUrl}accommodations/search");

    Map<String, dynamic> searchParams = {};
    if (query != null) searchParams['query'] = query;
    if (minPrice != null) searchParams['minPrice'] = minPrice;
    if (maxPrice != null) searchParams['maxPrice'] = maxPrice;
    if (minRating != null) searchParams['minRating'] = minRating;
    if (location != null) searchParams['location'] = location;
    if (propertyType != null) searchParams['propertyType'] = propertyType;

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(searchParams),
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);

        // Handle your API response format
        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

        // Fallback for other formats
        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to search accommodations: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error searching accommodations: $e");
      throw Exception("Failed to search accommodations: $e");
    }
  }
}
