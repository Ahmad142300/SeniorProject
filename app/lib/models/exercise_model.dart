// lib/exercise_model.dart
import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Returns the Euclidean length (norm) of a 3D vector.
double getLength(List<double> vector) {
  return sqrt(vector.map((e) => e * e).reduce((a, b) => a + b));
}

/// Computes the angle (in radians) between two 3D vectors.
double getAngle(List<double> v1, List<double> v2) {
  double dot = 0;
  double norm1 = 0;
  double norm2 = 0;
  for (int i = 0; i < 3; i++) {
    dot += v1[i] * v2[i];
    norm1 += v1[i] * v1[i];
    norm2 += v2[i] * v2[i];
  }
  norm1 = sqrt(norm1);
  norm2 = sqrt(norm2);
  if (norm1 == 0 || norm2 == 0) return 0.0;
  double cosAngle = dot / (norm1 * norm2);
  // Clamp the value to avoid numerical issues.
  cosAngle = cosAngle.clamp(-1.0, 1.0);
  return acos(cosAngle);
}

/// Extracts pose parameters for a squat exercise from a given [Pose].
///
/// If the [pose.landmarks] is empty, returns a vector of zeros with length 5.
/// Otherwise, it computes parameters such as:
///   - theta_neck: The angle between the vector [0, 0, -1] and the vector from mid-hip to nose.
///   - theta_k: (Placeholder) Average knee angle (to be refined as needed).
///   - theta_h: (Placeholder) Average hip angle (to be refined as needed).
///   - z: (Placeholder) A depth-related parameter.
///   - ky: (Placeholder) A parameter representing knee-to-foot distance.
///
/// All angles are rounded to two decimal places.
List<double> getParams(Pose pose, {String exercise = 'squats', bool all = false}) {
  // For squats, we expect to return 5 parameters.
  if (pose.landmarks.isEmpty) {
    return List.filled(5, 0.0);
  }

  // Create a map to hold landmark coordinates as 3D points.
  final Map<String, List<double>> points = {};

  // Helper to add a landmark if available.
  void addPoint(String name, PoseLandmarkType type) {
    final landmark = pose.landmarks[type];
    if (landmark != null) {
      points[name] = [landmark.x, landmark.y, landmark.z];
    }
  }

  // Add required landmarks.
  addPoint("NOSE", PoseLandmarkType.nose);
  addPoint("LEFT_EYE", PoseLandmarkType.leftEye);
  addPoint("RIGHT_EYE", PoseLandmarkType.rightEye);
  addPoint("MOUTH_LEFT", PoseLandmarkType.leftMouth);
  addPoint("MOUTH_RIGHT", PoseLandmarkType.rightMouth);
  addPoint("LEFT_SHOULDER", PoseLandmarkType.leftShoulder);
  addPoint("RIGHT_SHOULDER", PoseLandmarkType.rightShoulder);
  addPoint("LEFT_ELBOW", PoseLandmarkType.leftElbow);
  addPoint("RIGHT_ELBOW", PoseLandmarkType.rightElbow);
  addPoint("LEFT_WRIST", PoseLandmarkType.leftWrist);
  addPoint("RIGHT_WRIST", PoseLandmarkType.rightWrist);
  addPoint("LEFT_HIP", PoseLandmarkType.leftHip);
  addPoint("RIGHT_HIP", PoseLandmarkType.rightHip);
  addPoint("LEFT_KNEE", PoseLandmarkType.leftKnee);
  addPoint("RIGHT_KNEE", PoseLandmarkType.rightKnee);
  addPoint("LEFT_ANKLE", PoseLandmarkType.leftAnkle);
  addPoint("RIGHT_ANKLE", PoseLandmarkType.rightAnkle);
  addPoint("LEFT_HEEL", PoseLandmarkType.leftHeel);
  addPoint("RIGHT_HEEL", PoseLandmarkType.rightHeel);
  addPoint("LEFT_FOOT_INDEX", PoseLandmarkType.leftFootIndex);
  addPoint("RIGHT_FOOT_INDEX", PoseLandmarkType.rightFootIndex);

  // Compute midpoints if available.
  if (points.containsKey("LEFT_SHOULDER") && points.containsKey("RIGHT_SHOULDER")) {
    points["MID_SHOULDER"] = [
      (points["LEFT_SHOULDER"]![0] + points["RIGHT_SHOULDER"]![0]) / 2,
      (points["LEFT_SHOULDER"]![1] + points["RIGHT_SHOULDER"]![1]) / 2,
      (points["LEFT_SHOULDER"]![2] + points["RIGHT_SHOULDER"]![2]) / 2,
    ];
  }
  if (points.containsKey("LEFT_HIP") && points.containsKey("RIGHT_HIP")) {
    points["MID_HIP"] = [
      (points["LEFT_HIP"]![0] + points["RIGHT_HIP"]![0]) / 2,
      (points["LEFT_HIP"]![1] + points["RIGHT_HIP"]![1]) / 2,
      (points["LEFT_HIP"]![2] + points["RIGHT_HIP"]![2]) / 2,
    ];
  }

  // Compute theta_neck: angle between [0, 0, -1] and vector from MID_HIP to NOSE.
  double thetaNeck = 0.0;
  if (points.containsKey("NOSE") && points.containsKey("MID_HIP")) {
    thetaNeck = getAngle(
      [0, 0, -1],
      [
        points["NOSE"]![0] - points["MID_HIP"]![0],
        points["NOSE"]![1] - points["MID_HIP"]![1],
        points["NOSE"]![2] - points["MID_HIP"]![2],
      ],
    );
  }

  // For demonstration, we use placeholder values for the remaining parameters.
  // In a full implementation, you would calculate these using your domain knowledge.
  double thetaK = 0.0; // e.g., average knee angle
  double thetaH = 0.0; // e.g., hip angle
  double z = 0.0;      // e.g., depth parameter
  double ky = 0.0;     // e.g., knee-to-foot vertical difference

  // Optionally, apply any normalization factor if needed.
  // For now, we simply return the calculated angles and parameters.
  return [
    double.parse(thetaNeck.toStringAsFixed(2)),
    double.parse(thetaK.toStringAsFixed(2)),
    double.parse(thetaH.toStringAsFixed(2)),
    double.parse(z.toStringAsFixed(2)),
    double.parse(ky.toStringAsFixed(2))
  ];
}

/// (Optional) Converts a short label into a detailed description.
/// Here, you can expand labels as needed.
String labelFinalResults(String label) {
  const expandedLabels = {
    "c": "good Form",
    "k": "Knee Ahead",
    "h": "chest up",
    "r": "Back Wrongly Positioned",
    "x": "good Depth"
  };
  return expandedLabels[label] ?? label;
}
