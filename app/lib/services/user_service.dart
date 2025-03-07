// lib/services/user_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/user_model.dart';
import 'dart:convert';

class UserService {
  static const String _userKey = 'user_profile';

  // Save user profile
  static Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toMap());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Get user profile
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        return null;
      }

      final userMap = jsonDecode(userJson);
      return UserModel.fromMap(userMap);
    } catch (e) {
      print('Error retrieving user: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUser(UserModel updatedUser) async {
    try {
      final currentUser = await getUser();

      if (currentUser == null) {
        return await saveUser(updatedUser);
      }

      // Maintain the same ID
      final mergedUser = UserModel(
        id: currentUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        gender: updatedUser.gender,
        age: updatedUser.age,
        weight: updatedUser.weight,
        height: updatedUser.height,
        fitnessGoal: updatedUser.fitnessGoal,
        fitnessLevel: updatedUser.fitnessLevel,
      );

      return await saveUser(mergedUser);
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Delete user profile
  static Future<bool> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}