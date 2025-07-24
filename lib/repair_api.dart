import 'dart:convert';
import 'package:http/http.dart' as http;

class RepairApi {
  static const String baseUrl = 'http://your-api-url.com/api'; // Replace with your actual API URL

  // Create new repair service
  static Future<Map<String, dynamic>> createRepairService(Map<String, dynamic> repairData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addRepair'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(repairData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create repair service: $e');
    }
  }

  // Get all repair services
  static Future<Map<String, dynamic>> getRepairServices({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/repairs?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch repair services: $e');
    }
  }

  // Get repair service by ID
  static Future<Map<String, dynamic>> getRepairServiceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/repairs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch repair service: $e');
    }
  }

  // Search repair services
  static Future<Map<String, dynamic>> searchRepairServices({
    String? query,
    double? minCost,
    double? maxCost,
    double? minRating,
    String? location,
    String? serviceType,
    String? vehicleType,
    String? services,
  }) async {
    try {
      Map<String, String> queryParams = {};
      
      if (query != null) queryParams['query'] = query;
      if (minCost != null) queryParams['minCost'] = minCost.toString();
      if (maxCost != null) queryParams['maxCost'] = maxCost.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (location != null) queryParams['location'] = location;
      if (serviceType != null) queryParams['serviceType'] = serviceType;
      if (vehicleType != null) queryParams['vehicleType'] = vehicleType;
      if (services != null) queryParams['services'] = services;

      final uri = Uri.parse('$baseUrl/repairs/search').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to search repair services: $e');
    }
  }

  // Update repair service
  static Future<Map<String, dynamic>> updateRepairService(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/repairs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to update repair service: $e');
    }
  }

  // Delete repair service
  static Future<Map<String, dynamic>> deleteRepairService(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/repairs/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to delete repair service: $e');
    }
  }
}