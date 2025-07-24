import 'dart:convert';
import 'package:http/http.dart' as http;

class HousekeepingApi {
  static const String baseUrl = 'http://your-api-url.com/api'; // Replace with your actual API URL

  // Create new housekeeping service
  static Future<Map<String, dynamic>> createHousekeepingService(Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addhousekeeping'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(serviceData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create housekeeping service: $e');
    }
  }

  // Get all housekeeping services
  static Future<Map<String, dynamic>> getHousekeepingServices({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch housekeeping services: $e');
    }
  }

  // Get housekeeping service by ID
  static Future<Map<String, dynamic>> getHousekeepingServiceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch housekeeping service: $e');
    }
  }

  // Search housekeeping services
  static Future<Map<String, dynamic>> searchHousekeepingServices({
    String? query,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? serviceArea,
    String? serviceType,
    String? pricingMethod,
  }) async {
    try {
      Map<String, String> queryParams = {};
      
      if (query != null) queryParams['query'] = query;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (serviceArea != null) queryParams['serviceArea'] = serviceArea;
      if (serviceType != null) queryParams['serviceType'] = serviceType;
      if (pricingMethod != null) queryParams['pricingMethod'] = pricingMethod;

      final uri = Uri.parse('$baseUrl/housekeeping/search').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to search housekeeping services: $e');
    }
  }

  // Update housekeeping service
  static Future<Map<String, dynamic>> updateHousekeepingService(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/housekeeping/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to update housekeeping service: $e');
    }
  }

  // Delete housekeeping service
  static Future<Map<String, dynamic>> deleteHousekeepingService(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/housekeeping/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to delete housekeeping service: $e');
    }
  }

  // Get housekeeping service status
  static Future<Map<String, dynamic>> getHousekeepingServiceStatus(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/$id/status'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get housekeeping service status: $e');
    }
  }

  // Create booking for housekeeping service
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/housekeeping/booking'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(bookingData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get booking status
  static Future<Map<String, dynamic>> getBookingStatus(String bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/booking/$bookingId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get booking status: $e');
    }
  }

  // Get services by area
  static Future<Map<String, dynamic>> getServicesByArea(String area) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/area/$area'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get services by area: $e');
    }
  }

  // Get featured services
  static Future<Map<String, dynamic>> getFeaturedServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/featured'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get featured services: $e');
    }
  }

  // Rate and review service
  static Future<Map<String, dynamic>> rateService(String serviceId, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/housekeeping/$serviceId/review'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(reviewData),
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to rate service: $e');
    }
  }

  // Get service reviews
  static Future<Map<String, dynamic>> getServiceReviews(String serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/housekeeping/$serviceId/reviews'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to get service reviews: $e');
    }
  }
}