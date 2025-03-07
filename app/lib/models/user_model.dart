// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String fitnessGoal;
  final String fitnessLevel;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    required this.fitnessLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      fitnessGoal: map['fitnessGoal'] ?? '',
      fitnessLevel: map['fitnessLevel'] ?? '',
    );
  }
}

// lib/models/exercise_model.dart
class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final String targetMuscles;
  final String difficultyLevel;
  final String imageUrl;
  final List<String> instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.targetMuscles,
    required this.difficultyLevel,
    required this.imageUrl,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetMuscles': targetMuscles,
      'difficultyLevel': difficultyLevel,
      'imageUrl': imageUrl,
      'instructions': instructions,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetMuscles: map['targetMuscles'] ?? '',
      difficultyLevel: map['difficultyLevel'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      instructions: List<String>.from(map['instructions'] ?? []),
    );
  }
}