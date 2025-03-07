// lib/screens/onboarding/setup_screens.dart
import 'package:flutter/material.dart';
import 'package:app/home/home_screen.dart';
import 'package:app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Form controls for different pages
  String _selectedGender = 'Male';
  int _age = 28;
  double _weight = 75;
  String _weightUnit = 'kg';
  double _height = 165;
  String _selectedGoal = 'Lose Weight';
  String _activityLevel = 'Beginner';

  final List<String> _fitnessGoals = [
    'Lose Weight',
    'Gain Muscle',
    'Shape Body',
    'Improve Health',
    'Others'
  ];

  final List<String> _activityLevels = [
    'Beginner',
    'Intermediate',
    'Advance'
  ];

  void _saveUserProfile() async {
    final UserModel user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "User", // You'd get this from registration
      email: "user@example.com", // You'd get this from registration
      gender: _selectedGender,
      age: _age,
      weight: _weight,
      height: _height,
      fitnessGoal: _selectedGoal,
      fitnessLevel: _activityLevel,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(user.toMap()));

    // Navigate to home screen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final page - save and navigate
      _saveUserProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
                      onPressed: _previousPage,
                    ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.tertiary,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildGenderPage(),
                  _buildAgePage(),
                  _buildWeightPage(),
                  _buildHeightPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage < _totalPages - 1 ? 'Continue' : 'Finish',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's Your Gender?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "This helps us create a personalized experience for you.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 60),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedGender = 'Male'),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedGender == 'Male'
                            ? Theme.of(context).cardColor
                            : Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                        border: Border.all(
                          color: _selectedGender == 'Male'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.male,
                          size: 50,
                          color: _selectedGender == 'Male'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Male",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: _selectedGender == 'Male' ? FontWeight.bold : FontWeight.normal,
                        color: _selectedGender == 'Male'
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              GestureDetector(
                onTap: () => setState(() => _selectedGender = 'Female'),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedGender == 'Female'
                            ? Theme.of(context).cardColor
                            : Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                        border: Border.all(
                          color: _selectedGender == 'Female'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.female,
                          size: 50,
                          color: _selectedGender == 'Female'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Female",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: _selectedGender == 'Female' ? FontWeight.bold : FontWeight.normal,
                        color: _selectedGender == 'Female'
                            ? Theme.of(context).colorScheme.tertiary
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How Old Are You?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "This helps us tailor your workouts to your specific needs.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),

          // Large age display
          Center(
            child: Text(
              "$_age",
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Age slider/picker
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = _age - 2; i <= _age + 2; i++)
                  if (i >= 14 && i <= 90)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _age = i;
                        });
                      },
                      child: Container(
                        width: 60,
                        alignment: Alignment.center,
                        decoration: i == _age
                            ? BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        )
                            : null,
                        child: Text(
                          "$i",
                          style: TextStyle(
                            fontSize: i == _age ? 22 : 16,
                            fontWeight: i == _age ? FontWeight.bold : FontWeight.normal,
                            color: i == _age ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Age slider
          Slider(
            value: _age.toDouble(),
            min: 14,
            max: 90,
            divisions: 76,
            activeColor: Theme.of(context).colorScheme.tertiary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _age = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is Your Weight?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "This helps us calculate calorie burn and recommend appropriate exercises.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),

          // Weight unit selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_weightUnit == 'lb') {
                            _weight = _weight * 0.453592;
                          }
                          _weightUnit = 'kg';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _weightUnit == 'kg'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "kg",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _weightUnit == 'kg' ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_weightUnit == 'kg') {
                            _weight = _weight * 2.20462;
                          }
                          _weightUnit = 'lb';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _weightUnit == 'lb'
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "lb",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _weightUnit == 'lb' ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Large weight display
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _weight.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _weightUnit,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Weight slider
                Slider(
                  value: _weight,
                  min: _weightUnit == 'kg' ? 40 : 88,
                  max: _weightUnit == 'kg' ? 150 : 330,
                  activeColor: Theme.of(context).colorScheme.tertiary,
                  inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      _weight = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is Your Height?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "This helps us calculate your BMI and provide appropriate exercises.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),

          // Height visualization
          Expanded(
            child: Row(
              children: [
                // Height scale
                Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = 190; i >= 140; i -= 10)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "$i",
                            style: TextStyle(
                              fontSize: i == (_height.toInt() ~/ 10) * 10 ? 18 : 14,
                              fontWeight: i == (_height.toInt() ~/ 10) * 10 ? FontWeight.bold : FontWeight.normal,
                              color: i == (_height.toInt() ~/ 10) * 10
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Colors.white70,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Height indicator
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Person silhouette (simplified)
                      Container(
                        margin: EdgeInsets.only(bottom: 200 - _height / 2),
                        width: 100,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Height value
                      Positioned(
                        right: 30,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${_height.toInt()}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "cm",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Height slider
          Slider(
            value: _height,
            min: 140,
            max: 220,
            divisions: 80,
            activeColor: Theme.of(context).colorScheme.tertiary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _height = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    // Using SingleChildScrollView to handle overflow for this page
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What is Your Goal?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "We'll create a custom plan based on your fitness goals.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 30),

          // Goals as radio buttons
          for (String goal in _fitnessGoals)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedGoal == goal
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedGoal == goal
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedGoal == goal
                                ? Theme.of(context).colorScheme.tertiary
                                : Colors.white70,
                            width: 2,
                          ),
                        ),
                        child: _selectedGoal == goal
                            ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.black,
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        goal,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _selectedGoal == goal ? FontWeight.bold : FontWeight.normal,
                          color: _selectedGoal == goal
                              ? Theme.of(context).colorScheme.tertiary
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            "Physical Activity Level",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Activity level buttons
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _activityLevels.map((level) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activityLevel = level;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: _activityLevel == level
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _activityLevel == level ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Add extra padding at the bottom to ensure content isn't too close to the continue button
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}