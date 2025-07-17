import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://10.0.2.2:2000/api/";

  // HELPER METHODS
  static Future<http.Response> _makeRequest(String method, String endpoint, {Map<String, dynamic>? body, bool debug = false}) async {
    var url = Uri.parse("$baseUrl$endpoint");
    if (debug) {
      debugPrint("Making $method request to: $url");
      if (body != null) debugPrint("Request body: $body");
    }
    
    http.Response response;
    Map<String, String> headers = {"Content-Type": "application/json"};
    
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception("Unsupported HTTP method: $method");
      }
    } catch (e) {
      if (debug) debugPrint("Request failed: $e");
      rethrow;
    }
    
    if (debug) {
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
    return response;
  }

  static List<Map<String, dynamic>> _parseListResponse(http.Response response) {
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      
      if (responseData is Map && responseData.containsKey('success') && responseData['success'] == true) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }
      
      if (responseData is List) {
        return List<Map<String, dynamic>>.from(responseData);
      } else if (responseData is Map && responseData.containsKey('data')) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      }
    }
    throw Exception("Failed to parse response: ${response.statusCode}");
  }

  static Map<String, dynamic> _parseMapResponse(http.Response response) {
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        return Map<String, dynamic>.from(responseData['data']);
      }
    }
    throw Exception("Failed to parse response: ${response.statusCode}");
  }

  // USER METHODS
  static Future<void> adduser(Map udata) async {
    try {
      print(udata);
      final response = await _makeRequest('POST', 'add_data', body: Map<String, dynamic>.from(udata));
      if (response.statusCode == 200) {
        var data1 = jsonDecode(response.body.toString());
        print(data1);
      } else {
        throw Exception("Failed to add user");
      }
    } catch (e) {
      debugPrint("Error adding user: $e");
      throw Exception("Failed to add user: $e");
    }
  }

  static Future<void> getuser() async {
    try {
      final response = await _makeRequest('GET', 'get_data');
      if (response.statusCode == 200) {
        var data1 = jsonDecode(response.body.toString());
        print(data1);
      } else {
        throw Exception("Failed to get user");
      }
    } catch (e) {
      debugPrint("Error getting user: $e");
      throw Exception("Failed to get user: $e");
    }
  }

  static Future<bool> loginUser(Map loginData) async {
    try {
      final response = await _makeRequest('POST', 'login', body: Map<String, dynamic>.from(loginData));
      var data = jsonDecode(response.body.toString());
      if (response.statusCode == 200 && data['message'] == "Login successful") {
        print("Login Success: $data");
        return true;
      } else {
        print("Login Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  // ACCOMMODATION METHODS
  static Future<List<Map<String, dynamic>>> getAccommodations() async {
    try {
      final response = await _makeRequest('GET', 'accommodations');
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error fetching accommodations: $e");
      throw Exception("Failed to fetch accommodations: $e");
    }
  }

  static Future<Map<String, dynamic>> getAccommodationById(String id) async {
    try {
      final response = await _makeRequest('GET', 'accommodations/$id');
      return _parseMapResponse(response);
    } catch (e) {
      debugPrint("Error fetching accommodation details: $e");
      throw Exception("Failed to fetch accommodation details: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchAccommodations({
    String? query, double? minPrice, double? maxPrice, double? minRating, 
    String? location, String? propertyType,
  }) async {
    try {
      Map<String, dynamic> searchParams = {};
      if (query != null) searchParams['query'] = query;
      if (minPrice != null) searchParams['minPrice'] = minPrice;
      if (maxPrice != null) searchParams['maxPrice'] = maxPrice;
      if (minRating != null) searchParams['minRating'] = minRating;
      if (location != null) searchParams['location'] = location;
      if (propertyType != null) searchParams['propertyType'] = propertyType;

      final response = await _makeRequest('POST', 'accommodations/search', body: searchParams);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error searching accommodations: $e");
      throw Exception("Failed to search accommodations: $e");
    }
  }

  // GUIDE METHODS
  static Future<List<Map<String, dynamic>>> getGuides() async {
    try {
      final response = await _makeRequest('GET', 'guides', debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error fetching guides: $e");
      throw Exception("Failed to fetch guides: $e");
    }
  }

  static Future<Map<String, dynamic>> getGuideById(String id) async {
    try {
      final response = await _makeRequest('GET', 'guide/$id', debug: true);
      return _parseMapResponse(response);
    } catch (e) {
      debugPrint("Error fetching guide details: $e");
      throw Exception("Failed to fetch guide details: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchGuides({
    String? location, String? language, String? availability, int? page, int? limit,
  }) async {
    try {
      String endpoint = 'guides';
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
        endpoint = '$endpoint?$queryString';
      }

      final response = await _makeRequest('GET', endpoint, debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error searching guides: $e");
      throw Exception("Failed to search guides: $e");
    }
  }

  static Future<Map<String, dynamic>> addGuide(Map<String, dynamic> guideData) async {
    try {
      final response = await _makeRequest('POST', 'addGuide', body: guideData, debug: true);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to add guide");
      }
    } catch (e) {
      debugPrint("Error adding guide: $e");
      throw Exception("Failed to add guide: $e");
    }
  }

  static Future<Map<String, dynamic>> updateGuide(String id, Map<String, dynamic> guideData) async {
    try {
      final response = await _makeRequest('PUT', 'guide/$id', body: guideData, debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to update guide");
      }
    } catch (e) {
      debugPrint("Error updating guide: $e");
      throw Exception("Failed to update guide: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteGuide(String id) async {
    try {
      final response = await _makeRequest('DELETE', 'guide/$id', debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to delete guide");
      }
    } catch (e) {
      debugPrint("Error deleting guide: $e");
      throw Exception("Failed to delete guide: $e");
    }
  }

  // TAXI METHODS
  static Future<List<Map<String, dynamic>>> getTaxiDrivers() async {
    try {
      final response = await _makeRequest('GET', 'taxis', debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error fetching taxi drivers: $e");
      throw Exception("Failed to fetch taxi drivers: $e");
    }
  }

  static Future<Map<String, dynamic>> getTaxiDriverById(String id) async {
    try {
      final response = await _makeRequest('GET', 'taxi/$id', debug: true);
      return _parseMapResponse(response);
    } catch (e) {
      debugPrint("Error fetching taxi driver details: $e");
      throw Exception("Failed to fetch taxi driver details: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchTaxiDrivers({
    String? city, String? vehicleType, int? minCapacity, int? maxCapacity, 
    bool? hasAC, bool? hasLuggage, int? page, int? limit,
  }) async {
    try {
      String endpoint = 'taxis';
      Map<String, String> queryParams = {};
      if (city != null && city != 'all') queryParams['city'] = city;
      if (vehicleType != null && vehicleType != 'all') queryParams['vehicleType'] = vehicleType;
      if (minCapacity != null) queryParams['capacity'] = minCapacity.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      if (queryParams.isNotEmpty) {
        String queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _makeRequest('GET', endpoint, debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error searching taxi drivers: $e");
      throw Exception("Failed to search taxi drivers: $e");
    }
  }

  static Future<Map<String, dynamic>> addTaxiDriver(Map<String, dynamic> taxiData) async {
    try {
      final response = await _makeRequest('POST', 'addTaxi', body: taxiData, debug: true);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to add taxi driver");
      }
    } catch (e) {
      debugPrint("Error adding taxi driver: $e");
      throw Exception("Failed to add taxi driver: $e");
    }
  }

  static Future<Map<String, dynamic>> updateTaxiDriver(String id, Map<String, dynamic> taxiData) async {
    try {
      final response = await _makeRequest('PUT', 'taxi/$id', body: taxiData, debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to update taxi driver");
      }
    } catch (e) {
      debugPrint("Error updating taxi driver: $e");
      throw Exception("Failed to update taxi driver: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteTaxiDriver(String id) async {
    try {
      final response = await _makeRequest('DELETE', 'taxi/$id', debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to delete taxi driver");
      }
    } catch (e) {
      debugPrint("Error deleting taxi driver: $e");
      throw Exception("Failed to delete taxi driver: $e");
    }
  }

  // COMMUNICATION METHODS
  static Future<List<Map<String, dynamic>>> getCommunicationServices() async {
    try {
      final response = await _makeRequest('GET', 'communications', debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error fetching communication services: $e");
      throw Exception("Failed to fetch communication services: $e");
    }
  }

  static Future<Map<String, dynamic>> getCommunicationServiceById(String id) async {
    try {
      final response = await _makeRequest('GET', 'communication/$id', debug: true);
      return _parseMapResponse(response);
    } catch (e) {
      debugPrint("Error fetching communication service details: $e");
      throw Exception("Failed to fetch communication service details: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> searchCommunicationServices({
    String? serviceType, String? paymentMethod, String? coverageArea, 
    String? query, int? page, int? limit,
  }) async {
    try {
      String endpoint = 'communications';
      Map<String, String> queryParams = {};
      if (serviceType != null && serviceType != 'all') queryParams['serviceType'] = serviceType;
      if (paymentMethod != null && paymentMethod != 'all') queryParams['paymentMethod'] = paymentMethod;
      if (coverageArea != null && coverageArea != 'all') queryParams['coverageArea'] = coverageArea;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      if (queryParams.isNotEmpty) {
        String queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _makeRequest('GET', endpoint, debug: true);
      return _parseListResponse(response);
    } catch (e) {
      debugPrint("Error searching communication services: $e");
      throw Exception("Failed to search communication services: $e");
    }
  }

  static Future<Map<String, dynamic>> addCommunicationService(Map<String, dynamic> serviceData) async {
    try {
      final response = await _makeRequest('POST', 'addCommunication', body: serviceData, debug: true);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to add communication service");
      }
    } catch (e) {
      debugPrint("Error adding communication service: $e");
      throw Exception("Failed to add communication service: $e");
    }
  }

  static Future<Map<String, dynamic>> updateCommunicationService(String id, Map<String, dynamic> serviceData) async {
    try {
      final response = await _makeRequest('PUT', 'communication/$id', body: serviceData, debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to update communication service");
      }
    } catch (e) {
      debugPrint("Error updating communication service: $e");
      throw Exception("Failed to update communication service: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteCommunicationService(String id) async {
    try {
      final response = await _makeRequest('DELETE', 'communication/$id', debug: true);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to delete communication service");
      }
    } catch (e) {
      debugPrint("Error deleting communication service: $e");
      throw Exception("Failed to delete communication service: $e");
    }
  }

  // BOOKING METHODS
  static Future<Map<String, dynamic>> bookGuide({
    required String guideId, required String userId, required String tourDate,
    required String tourLocation, String? message,
  }) async {
    try {
      Map<String, dynamic> bookingData = {
        'guideId': guideId, 'userId': userId, 'tourDate': tourDate,
        'tourLocation': tourLocation, if (message != null) 'message': message,
      };
      final response = await _makeRequest('POST', 'bookGuide', body: bookingData, debug: true);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to book guide");
      }
    } catch (e) {
      debugPrint("Error booking guide: $e");
      throw Exception("Failed to book guide: $e");
    }
  }

  static Future<Map<String, dynamic>> bookTaxi({
    required String taxiId, required String userId, required String pickupLocation,
    required String dropoffLocation, required String tripDate, required String tripTime,
    String? message,
  }) async {
    try {
      Map<String, dynamic> bookingData = {
        'taxiId': taxiId, 'userId': userId, 'pickupLocation': pickupLocation,
        'dropoffLocation': dropoffLocation, 'tripDate': tripDate, 'tripTime': tripTime,
        if (message != null) 'message': message,
      };
      final response = await _makeRequest('POST', 'bookTaxi', body: bookingData, debug: true);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? "Failed to book taxi");
      }
    } catch (e) {
      debugPrint("Error booking taxi: $e");
      throw Exception("Failed to book taxi: $e");
    }
  }

  // UTILITY METHODS
  static Future<bool> testConnection() async {
    try {
      final response = await _makeRequest('GET', 'guides');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Connection test failed: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAppStatus() async {
    try {
      final response = await _makeRequest('GET', 'status');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to get app status");
      }
    } catch (e) {
      debugPrint("Error getting app status: $e");
      throw Exception("Failed to get app status: $e");
    }
  }
}