// lib/utils/user_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  // Save user data after successful login
  static Future<bool> saveUserData({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userNameKey, userName);
      await prefs.setString(_userEmailKey, userEmail);
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Get current user ID
  static Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get current user name
  static Future<String?> getUserName() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return {
        'userId': prefs.getString(_userIdKey),
        'userName': prefs.getString(_userNameKey),
        'userEmail': prefs.getString(_userEmailKey),
      };
    } catch (e) {
      print('Error getting user data: $e');
      return {'userId': null, 'userName': null, 'userEmail': null};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    String? userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  // Clear user data (logout)
  static Future<bool> clearUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }
}
