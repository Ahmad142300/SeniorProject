// lib/screens/home/exercise_list_screen.dart
import 'package:flutter/material.dart';
import 'package:app/screens/exercises/exercise_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  const ExerciseListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Exercises"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Wrap entire content in ScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured exercise banner
              Container(
                width: double.infinity,
                height: 220, // Increased height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.fitness_center,
                        size: 150,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Make it take minimum vertical space
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "FEATURED",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Smart Workout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22, // Reduced from 24 to save space
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "AI-guided exercises with real-time feedback",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              // Start featured workout
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Slightly smaller padding
                            ),
                            child: const Text("START NOW"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Key Exercises",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Exercise list (just 3)
              _buildExerciseCard(
                context,
                "Push-ups",
                "Chest, Shoulders, Triceps",
                "Beginner",
                Icons.fitness_center,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseScreen(exerciseName: "Push-ups"),
                    ),
                  );
                },
              ),
              _buildExerciseCard(
                context,
                "Squats",
                "Quadriceps, Hamstrings, Glutes",
                "Beginner",
                Icons.accessibility_new,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseScreen(exerciseName: "Squats"),
                    ),
                  );
                },
              ),
              _buildExerciseCard(
                context,
                "Shoulder Press",
                "Shoulders, Triceps",
                "Intermediate",
                Icons.fitness_center,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExerciseScreen(exerciseName: "Shoulder Press"),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context,
      String title,
      String muscles,
      String level,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Exercise icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 40,
                ),
              ),

              const SizedBox(width: 16),

              // Exercise information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      muscles,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.tertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}