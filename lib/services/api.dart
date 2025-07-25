import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://localhost:2000/api/";

  // ==================== USER METHODS ====================
  static adduser(Map udata) async {
    var url = Uri.parse("${baseUrl}add_data");
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(udata),
      );
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
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
        print(jsonDecode(res.body));
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
      var data = jsonDecode(res.body);
      return res.statusCode == 200 && data['message'] == "Login successful";
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  // ==================== ACCOMMODATION METHODS ====================
  static Future<List<Map<String, dynamic>>> getAccommodations() async {
    var url = Uri.parse("${baseUrl}accommodations");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        if (responseData is Map && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          return List<Map<String, dynamic>>.from(responseData);
        }
      } else {
        throw Exception("Failed to fetch accommodations");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  static Future<Map<String, dynamic>> getAccommodationById(String id) async {
    var url = Uri.parse("${baseUrl}accommodations/$id");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchAccommodations(
      {String? query}) async {
    var url = Uri.parse("${baseUrl}accommodations/search");
    Map<String, dynamic> params = {};
    if (query != null) params['query'] = query;

    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(params));
      return List<Map<String, dynamic>>.from(jsonDecode(res.body)['data']);
    } catch (e) {
      throw Exception("Search failed: $e");
    }
  }

  // ==================== GUIDE METHODS ====================
  static Future<List<Map<String, dynamic>>> getGuides() async {
    var url = Uri.parse("${baseUrl}guides");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      var data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } catch (e) {
      throw Exception("Failed to fetch guides: $e");
    }
  }

  static Future<Map<String, dynamic>> getGuideById(String id) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Failed to fetch guide details: $e");
    }
  }

  static Future<Map<String, dynamic>> addGuide(
      Map<String, dynamic> guideData) async {
    var url = Uri.parse("${baseUrl}addGuide");
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(guideData));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Add guide failed: $e");
    }
  }

  static Future<Map<String, dynamic>> updateGuide(
      String id, Map<String, dynamic> data) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    try {
      final res = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Update guide failed: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteGuide(String id) async {
    var url = Uri.parse("${baseUrl}guide/$id");
    try {
      final res =
          await http.delete(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Delete guide failed: $e");
    }
  }

  // ==================== TAXI METHODS ====================
  static Future<List<Map<String, dynamic>>> getTaxiDrivers() async {
    var url = Uri.parse("${baseUrl}taxis");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      return List<Map<String, dynamic>>.from(jsonDecode(res.body)['data']);
    } catch (e) {
      throw Exception("Failed to fetch taxis: $e");
    }
  }

  static Future<Map<String, dynamic>> getTaxiDriverById(String id) async {
    var url = Uri.parse("${baseUrl}taxi/$id");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Taxi details fetch error: $e");
    }
  }

  static Future<Map<String, dynamic>> addTaxiDriver(
      Map<String, dynamic> taxiData) async {
    var url = Uri.parse("${baseUrl}addTaxi");
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(taxiData));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Add taxi failed: $e");
    }
  }

  static Future<Map<String, dynamic>> updateTaxiDriver(
      String id, Map<String, dynamic> taxiData) async {
    var url = Uri.parse("${baseUrl}taxi/$id");
    try {
      final res = await http.put(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(taxiData));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Taxi update error: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteTaxiDriver(String id) async {
    var url = Uri.parse("${baseUrl}taxi/$id");
    try {
      final res =
          await http.delete(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Taxi delete error: $e");
    }
  }

  // ==================== BOOKING METHODS ====================
  static Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    var url = Uri.parse("${baseUrl}bookings");
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(bookingData));
      return res.statusCode == 201
          ? {'success': true, 'data': jsonDecode(res.body)}
          : {'success': false, 'error': jsonDecode(res.body)['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getBookingStatus(String bookingId) async {
    var url = Uri.parse("${baseUrl}bookings/$bookingId/status");
    try {
      final res = await http.get(url);
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> bookGuide({
    required String guideId,
    required String userId,
    required String tourDate,
    required String tourLocation,
    String? message,
  }) async {
    var url = Uri.parse("${baseUrl}bookGuide");
    Map<String, dynamic> data = {
      'guideId': guideId,
      'userId': userId,
      'tourDate': tourDate,
      'tourLocation': tourLocation,
      if (message != null) 'message': message,
    };
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Booking guide failed: $e");
    }
  }

  static Future<Map<String, dynamic>> bookTaxi({
    required String taxiId,
    required String userId,
    required String pickupLocation,
    required String dropoffLocation,
    required String tripDate,
    required String tripTime,
    String? message,
  }) async {
    var url = Uri.parse("${baseUrl}bookTaxi");
    Map<String, dynamic> data = {
      'taxiId': taxiId,
      'userId': userId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'tripDate': tripDate,
      'tripTime': tripTime,
      if (message != null) 'message': message,
    };
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Booking taxi failed: $e");
    }
  }
// ==================== RESTUARANT METHODS ====================

  static Future<List<Map<String, dynamic>>> getRestaurants() async {
    var url = Uri.parse("${baseUrl}restaurants");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      var data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } catch (e) {
      throw Exception("Failed to fetch restaurants: $e");
    }
  }

  static Future<Map<String, dynamic>> getRestaurantById(String id) async {
    var url = Uri.parse("${baseUrl}restaurant/$id");
    try {
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      return jsonDecode(res.body);
    } catch (e) {
      throw Exception("Failed to fetch restaurant details: $e");
    }
  }
}
