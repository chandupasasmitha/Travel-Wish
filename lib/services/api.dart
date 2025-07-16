import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://10.0.2.2:2000/api/";

  // USER METHODS
  static adduser(Map udata) async {
    print(udata);
    var url = Uri.parse("${baseUrl}add_data");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(udata),
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

  // ACCOMMODATION METHODS
  static Future<List<Map<String, dynamic>>> getAccommodations() async {
    var url = Uri.parse("${baseUrl}accommodations");
    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);

        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

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

        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

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

  // GUIDE METHODS
  static Future<List<Map<String, dynamic>>> getGuides() async {
    var url = Uri.parse("${baseUrl}guides");
    debugPrint("Making request to: $url");
    
    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Response status: ${res.statusCode}");
      debugPrint("Response body: ${res.body}");

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        debugPrint("Decoded response: $responseData");

        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to fetch guides: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching guides: $e");
      throw Exception("Failed to fetch guides: $e");
    }
  }

  static Future<Map<String, dynamic>> getGuideById(String id) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    debugPrint("Making request to: $url");
    
    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Response status: ${res.statusCode}");
      debugPrint("Response body: ${res.body}");

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
        throw Exception("Failed to fetch guide details: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching guide details: $e");
      throw Exception("Failed to fetch guide details: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchGuides({
    String? location,
    String? language,
    String? availability,
    int? page,
    int? limit,
  }) async {
    var url = Uri.parse("${baseUrl}guides");

    Map<String, String> queryParams = {};
    if (location != null && location != 'all') queryParams['location'] = location;
    if (language != null && language != 'all') queryParams['language'] = language;
    if (availability != null && availability != 'all') queryParams['availability'] = availability;
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    if (queryParams.isNotEmpty) {
      String queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url = Uri.parse("${url}?$queryString");
    }

    debugPrint("Making search request to: $url");

    try {
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Search response status: ${res.statusCode}");
      debugPrint("Search response body: ${res.body}");

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);

        if (responseData is Map &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          }
        }

        if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        } else if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed to search guides: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error searching guides: $e");
      throw Exception("Failed to search guides: $e");
    }
  }

  static Future<Map<String, dynamic>> addGuide(Map<String, dynamic> guideData) async {
    var url = Uri.parse("${baseUrl}addGuide");
    debugPrint("Making add guide request to: $url");
    debugPrint("Guide data: $guideData");
    
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(guideData),
      );

      debugPrint("Add guide response status: ${res.statusCode}");
      debugPrint("Add guide response body: ${res.body}");

      if (res.statusCode == 201) {
        var responseData = jsonDecode(res.body);
        return responseData;
      } else {
        var errorData = jsonDecode(res.body);
        throw Exception(errorData['error'] ?? "Failed to add guide");
      }
    } catch (e) {
      debugPrint("Error adding guide: $e");
      throw Exception("Failed to add guide: $e");
    }
  }

  static Future<Map<String, dynamic>> updateGuide(String id, Map<String, dynamic> guideData) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    debugPrint("Making update guide request to: $url");
    debugPrint("Update data: $guideData");
    
    try {
      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(guideData),
      );

      debugPrint("Update guide response status: ${res.statusCode}");
      debugPrint("Update guide response body: ${res.body}");

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        return responseData;
      } else {
        var errorData = jsonDecode(res.body);
        throw Exception(errorData['error'] ?? "Failed to update guide");
      }
    } catch (e) {
      debugPrint("Error updating guide: $e");
      throw Exception("Failed to update guide: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteGuide(String id) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    debugPrint("Making delete guide request to: $url");
    
    try {
      final res = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("Delete guide response status: ${res.statusCode}");
      debugPrint("Delete guide response body: ${res.body}");

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        return responseData;
      } else {
        var errorData = jsonDecode(res.body);
        throw Exception(errorData['error'] ?? "Failed to delete guide");
      }
    } catch (e) {
      debugPrint("Error deleting guide: $e");
      throw Exception("Failed to delete guide: $e");
    }
  }

  // BOOKING METHODS (Optional - if you want to add booking functionality)
  static Future<Map<String, dynamic>> bookGuide({
    required String guideId,
    required String userId,
    required String tourDate,
    required String tourLocation,
    String? message,
  }) async {
    var url = Uri.parse("${baseUrl}bookGuide");
    
    Map<String, dynamic> bookingData = {
      'guideId': guideId,
      'userId': userId,
      'tourDate': tourDate,
      'tourLocation': tourLocation,
      if (message != null) 'message': message,
    };

    debugPrint("Making booking request to: $url");
    debugPrint("Booking data: $bookingData");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bookingData),
      );

      debugPrint("Booking response status: ${res.statusCode}");
      debugPrint("Booking response body: ${res.body}");

      if (res.statusCode == 201 || res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        return responseData;
      } else {
        var errorData = jsonDecode(res.body);
        throw Exception(errorData['error'] ?? "Failed to book guide");
      }
    } catch (e) {
      debugPrint("Error booking guide: $e");
      throw Exception("Failed to book guide: $e");
    }
  }

  // UTILITY METHODS
  static Future<bool> testConnection() async {
    try {
      var url = Uri.parse("${baseUrl}guides");
      final res = await http.get(url);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Connection test failed: $e");
      return false;
    }
  }
}