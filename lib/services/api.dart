import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = "http://10.0.2.2:2000/api/";

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
    // Simulate API delay
    await Future.delayed(Duration(seconds: 1));

    // Mock restaurant data
    return [
      {
        '_id': '1',
        'name': 'Spice Garden',
        'location': 'Colombo',
        'rating': 4.5,
        'priceRange': '\$\$',
        'distance': 2.3,
        'isOpen': true,
        'deliveryTime': '25-35 min',
        'cuisineTypes': ['Sri Lankan', 'Indian', 'Thai'],
      },
      {
        '_id': '2',
        'name': 'Pizza Palace',
        'location': 'Gampaha',
        'rating': 4.2,
        'priceRange': '\$\$',
        'distance': 5.1,
        'isOpen': true,
        'deliveryTime': '30-40 min',
        'cuisineTypes': ['Italian', 'American'],
      },
      {
        '_id': '3',
        'name': 'Dragon House',
        'location': 'Kandy',
        'rating': 4.7,
        'priceRange': '\$\$\$',
        'distance': 1.8,
        'isOpen': false,
        'deliveryTime': '20-30 min',
        'cuisineTypes': ['Chinese', 'Japanese'],
      },
      {
        '_id': '4',
        'name': 'Curry Leaf',
        'location': 'Colombo',
        'rating': 4.3,
        'priceRange': '\$',
        'distance': 3.2,
        'isOpen': true,
        'deliveryTime': '35-45 min',
        'cuisineTypes': ['Sri Lankan', 'Indian'],
      },
      {
        '_id': '5',
        'name': 'Taco Fiesta',
        'location': 'Galle',
        'rating': 4.1,
        'priceRange': '\$\$',
        'distance': 4.5,
        'isOpen': true,
        'deliveryTime': '25-35 min',
        'cuisineTypes': ['Mexican', 'American'],
      },
    ];
  }

  static Future<Map<String, dynamic>> getRestaurantById(String id) async {
    // Simulate API delay
    await Future.delayed(Duration(seconds: 1));

    // Mock detailed restaurant data
    Map<String, dynamic> mockData = {
      '1': {
        'data': {
          '_id': '1',
          'name': 'Spice Garden',
          'address': '123 Main Street, Colombo 03, Sri Lanka',
          'contact': '+94 11 234 5678',
          'rating': 4.5,
          'reviewCount': 245,
          'priceRange': '\$\$',
          'isOpen': true,
          'deliveryTime': '25-35 min',
          'cuisineTypes': ['Sri Lankan', 'Indian', 'Thai'],
          'description':
              'Experience authentic Sri Lankan and Indian cuisine in a warm, welcoming atmosphere. Our chefs use traditional spices and cooking methods to create unforgettable flavors.',
          'popularDishes': [
            {
              'name': 'Kottu Roti',
              'description': 'Traditional Sri Lankan street food',
              'price': 850
            },
            {
              'name': 'Chicken Curry',
              'description': 'Spicy authentic curry',
              'price': 1200
            },
            {
              'name': 'Fish Ambul Thiyal',
              'description': 'Sour fish curry',
              'price': 1350
            }
          ],
          'openingHours': {
            'monday': '11:00 AM - 10:00 PM',
            'tuesday': '11:00 AM - 10:00 PM',
            'wednesday': '11:00 AM - 10:00 PM',
            'thursday': '11:00 AM - 10:00 PM',
            'friday': '11:00 AM - 11:00 PM',
            'saturday': '11:00 AM - 11:00 PM',
            'sunday': '12:00 PM - 9:00 PM'
          }
        }
      },
      '2': {
        'data': {
          '_id': '2',
          'name': 'Pizza Palace',
          'address': '456 Gampaha Road, Gampaha, Sri Lanka',
          'contact': '+94 33 567 8901',
          'rating': 4.2,
          'reviewCount': 189,
          'priceRange': '\$\$',
          'isOpen': true,
          'deliveryTime': '30-40 min',
          'cuisineTypes': ['Italian', 'American'],
          'description':
              'Serving the finest Italian pizzas and American classics. Made with fresh ingredients and traditional recipes passed down through generations.',
          'popularDishes': [
            {
              'name': 'Margherita Pizza',
              'description': 'Classic tomato and mozzarella',
              'price': 1800
            },
            {
              'name': 'Pepperoni Pizza',
              'description': 'Pepperoni with cheese',
              'price': 2200
            },
            {
              'name': 'Chicken Wings',
              'description': 'Buffalo style wings',
              'price': 950
            }
          ],
          'openingHours': {
            'monday': '12:00 PM - 11:00 PM',
            'tuesday': '12:00 PM - 11:00 PM',
            'wednesday': '12:00 PM - 11:00 PM',
            'thursday': '12:00 PM - 11:00 PM',
            'friday': '12:00 PM - 12:00 AM',
            'saturday': '12:00 PM - 12:00 AM',
            'sunday': '1:00 PM - 10:00 PM'
          }
        }
      },
      '3': {
        'data': {
          '_id': '3',
          'name': 'Dragon House',
          'address': '789 Kandy Road, Kandy, Sri Lanka',
          'contact': '+94 81 345 6789',
          'rating': 4.7,
          'reviewCount': 312,
          'priceRange': '\$\$\$',
          'isOpen': false,
          'deliveryTime': '20-30 min',
          'cuisineTypes': ['Chinese', 'Japanese'],
          'description':
              'Authentic Chinese and Japanese cuisine prepared by master chefs. Experience the perfect blend of traditional flavors and modern presentation.',
          'popularDishes': [
            {
              'name': 'Sweet & Sour Pork',
              'description': 'Traditional Chinese style',
              'price': 2200
            },
            {
              'name': 'Chicken Fried Rice',
              'description': 'Wok-fried with vegetables',
              'price': 1650
            },
            {
              'name': 'Sushi Platter',
              'description': 'Fresh assorted sushi',
              'price': 3200
            }
          ],
          'openingHours': {
            'monday': '6:00 PM - 11:00 PM',
            'tuesday': '6:00 PM - 11:00 PM',
            'wednesday': '6:00 PM - 11:00 PM',
            'thursday': '6:00 PM - 11:00 PM',
            'friday': '6:00 PM - 12:00 AM',
            'saturday': '6:00 PM - 12:00 AM',
            'sunday': 'Closed'
          }
        }
      }
    };

    return mockData[id] ??
        {
          'data': {
            '_id': id,
            'name': 'Restaurant Not Found',
            'error': 'Restaurant details not available'
          }
        };
  }
}
