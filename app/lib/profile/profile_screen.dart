// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/user_model.dart';
import 'dart:convert';
import 'package:app/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_profile');

    setState(() {
      if (userJson != null) {
        _user = UserModel.fromMap(jsonDecode(userJson));
      }
      _isLoading = false;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Theme.of(context).colorScheme.tertiary,
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? _buildNoProfile()
          : _buildProfile(),
    );
  }

  Widget _buildNoProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            "No profile found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please complete the setup process",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("GO TO LOGIN"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            _user?.name ?? "User",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Text(
            _user?.email ?? "user@example.com",
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 32),

          // User stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem("Weight", "${_user?.weight.toInt() ?? 0} kg"),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem("Height", "${_user?.height.toInt() ?? 0} cm"),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem("Age", "${_user?.age ?? 0} years"),
            ],
          ),

          const SizedBox(height: 32),

          // Profile details
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildProfileItem("Gender", _user?.gender ?? "Not set", Icons.person_outline),
                _buildDivider(),
                _buildProfileItem("Fitness Goal", _user?.fitnessGoal ?? "Not set", Icons.flag_outlined),
                _buildDivider(),
                _buildProfileItem("Fitness Level", _user?.fitnessLevel ?? "Not set", Icons.fitness_center_outlined),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Edit profile button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit profile
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text("EDIT PROFILE"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_outlined),
              label: const Text("LOGOUT"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.tertiary,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.white12,
    );
  }
}