// lib/screens/exercises/exercise_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' show pi;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:app/models/exercise_model.dart';


class ExerciseScreen extends StatefulWidget {
  final String exerciseName;

  const ExerciseScreen({
    Key? key,
    required this.exerciseName,
  }) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with WidgetsBindingObserver {
  // The Interpreter is the object that loads and runs the TensorFlow Lite model.
  // In this case, it is used to detect the pose of the user in the camera stream.
  // The model is loaded from the assets folder and is specific to the exercise
  // being performed. The model takes a camera image as input and outputs a list
  // of poses, which are then used to track the user's movement and provide feedback.
  Interpreter? _interpreter;
  bool _isCameraInitialized = false;
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  List<Pose> _poses = [];
  CustomPaint? _customPaint;

  bool _isPreparing = true;
  int _countdown = 3;
  int _repCount = 0;
  int _targetReps = 10;
  double _accuracy = 0.8;
  Timer? _processingTimer;
  DateTime _startTime = DateTime.now();
  bool _isProcessingFrame = false;

  // Exercise state tracking
  bool _isInDownPosition = false;
  int _framesSinceLastRep = 0;

  final FlutterTts _flutterTts = FlutterTts();
  DateTime _lastFeedbackTime = DateTime.now();
  List<String> _feedbacks = [
    "Good form! Keep your body aligned.",
    "Keep your back straight.",
    "Great job! Keep going!",
    "Focus on controlled movements.",
    "Excellent pace!"
  ];
  String _currentFeedback = "Good form! Keep your body aligned.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadModel();
    _initPoseDetector();
    _initializeCamera();
    _initTts();


    // Start countdown
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown = 2;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _countdown = 1;
            });

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  _isPreparing = false;
                  _startTime = DateTime.now();
                });
                _startPoseDetection();
                _speak("Starting ${widget.exerciseName}. Position yourself in frame.");
              }
            });
          }
        });
      }
    });
  }

  Future<void> _loadModel() async {
    try {
      // The file "working_model_1.tflite" must be declared in pubspec.yaml under assets
      _interpreter = await Interpreter.fromAsset("assets/working_model_1.tflite");
      print("TFLite model loaded successfully!");
    } catch (e) {
      print("Error loading TFLite model: $e");
    }
  }

  void _initPoseDetector() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );
    _poseDetector = PoseDetector(options: options);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (DateTime.now().difference(_lastFeedbackTime).inSeconds < 3) {
      return; // Don't give feedback too frequently
    }

    _lastFeedbackTime = DateTime.now();
    await _flutterTts.speak(text);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("No cameras found");
        return;
      }

      // Try to find front camera
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low, // Using medium for better quality while maintaining performance
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startPoseDetection() {
    if (_cameraController == null) return;

    // Process frames at regular intervals
    _processingTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (_isProcessingFrame || !mounted || _isPreparing) return;

      try {
        _isProcessingFrame = true;

        // Capture a picture with the current camera controller
        final xFile = await _cameraController!.takePicture();
        final inputImage = InputImage.fromFilePath(xFile.path);

        // Process image with pose detector
        final poses = await _poseDetector!.processImage(inputImage);

        // Clean up the temp file
        await File(xFile.path).delete().catchError((e) => print('Error deleting temp file: $e'));

        if (mounted) {
          setState(() {
            // Store poses
            _poses = poses;

            // Check if we have valid poses with enough landmarks
            if (poses.isNotEmpty && poses.first.landmarks.length > 10) {
              // Create custom paint only when we have a valid pose
              _customPaint = CustomPaint(
                painter: PosePainter(
                  poses,
                  Size(_cameraController!.value.previewSize!.height,
                      _cameraController!.value.previewSize!.width),
                  InputImageRotation.rotation90deg,
                ),
              );

              _processExerciseLogic(poses.first);
            } else {
              // Explicitly clear the custom paint when no valid pose is detected
              _customPaint = null;
              _currentFeedback = "Position yourself in frame";
            }
          });
        }
      } catch (e) {
        print('Error processing frame: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }
  Future<void> _processExerciseLogic(Pose pose) async {
    // 1. Extract parameters using getParams() for squats.
    List<double> params = getParams(pose, exercise: 'squats');
    print("Extracted parameters: $params");

    if (_interpreter != null) {
      // 2. Prepare input and output buffers.
      var input = [params]; // shape: [1, N]
      var output = List.filled(5, 0.0).reshape([1, 5]); // model outputs 5 values

      try {
        // 3. Run inference.
        _interpreter!.run(input, output);
        print("Raw model output: $output");

        // 4. Process the output as in the Python code.
        List<String> outputNames = ['c', 'k', 'h', 'r', 'x', 'i'];
        List<double> out = List.from(output[0]);

        out[0] *= 0.7;
        out[1] *= 1.7;
        out[2] *= 4;
        out[3] *= 0;
        out[4] *= 5;

        double sumOut = out.reduce((a, b) => a + b);
        for (int i = 0; i < out.length; i++) {
          out[i] = out[i] * (1 / sumOut);
        }

        // Adjust the third output value.
        out[2] += 0.1;

        // 5. Build the label string from indices 1 to 3.
        String label = "";
        for (int i = 1; i < 4; i++) {
          if (out[i] > 0.5) {
            label += outputNames[i];
          }
        }
        if (label.isEmpty) {
          label = "c";
        }
        // Append 'x' if output[4] > 0.15 and the label is 'c'.
        if (out[4] > 0.15 && label == "c") {
          label += "x";
        }
        // Skip "cx" since it has no label – set it back to "c".
        if (label == "cx") {
          label = "c";
        }

        // 6. Get the full feedback using labelFinalResults().
        String fullFeedback = labelFinalResults(label);
        print("Final label: $label, Feedback: $fullFeedback");

        // 7. Provide vocal feedback.
        await _speak(fullFeedback);

        // 8. Update the UI with the final feedback.
        setState(() {
          _currentFeedback = fullFeedback;
        });
      } catch (e) {
        print("Error running inference: $e");
        setState(() {
          _currentFeedback = "Inference error.";
        });
      }
    } else {
      // If interpreter is null, simply log the landmark count.
      int visibleLandmarks = 0;
      pose.landmarks.forEach((_, landmark) {
        visibleLandmarks++;
      });
      print("Detected $visibleLandmarks landmarks");
      setState(() {
        _currentFeedback = "Detected $visibleLandmarks landmarks";
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getFeedbackColor() {
    if (_accuracy >= 0.85) {
      return Colors.green.withOpacity(0.3);
    } else if (_accuracy >= 0.7) {
      return Colors.orange.withOpacity(0.3);
    } else {
      return Colors.red.withOpacity(0.3);
    }
  }

  IconData _getFeedbackIcon() {
    if (_accuracy >= 0.85) {
      return Icons.check_circle;
    } else if (_accuracy >= 0.7) {
      return Icons.info_outline;
    } else {
      return Icons.warning_amber;
    }
  }

  void _endExercise() {
    _processingTimer?.cancel();
    _poseDetector?.close();

    // Navigate back after a short delay
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      _poseDetector?.close();
    } else if (state == AppLifecycleState.resumed) {
      _initPoseDetector();
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _cameraController?.dispose();
    _poseDetector?.close();
    _flutterTts.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final elapsedSeconds = _isPreparing
        ? 0
        : DateTime.now().difference(_startTime).inSeconds;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized)
            SizedBox.expand(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Simple camera preview with mirroring
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: CameraPreview(_cameraController!),
                  ),

                  // Pose overlay - positioned to fill the same space as the camera
                  if (!_isPreparing && _customPaint != null)
                    Positioned.fill(
                      child: _customPaint!,
                    ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          // UI Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top info
                  if (!_isPreparing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(elapsedSeconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$_repCount / $_targetReps",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Countdown or feedback
                  if (_isPreparing)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Ready",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _countdown.toString(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Position yourself in frame",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Feedback",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getFeedbackColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFeedbackIcon(),
                                  color: _accuracy >= 0.85 ? Colors.green :
                                  _accuracy >= 0.7 ? Colors.orange : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentFeedback,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Progress bar for reps
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Progress",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "$_repCount/$_targetReps reps",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _repCount / _targetReps,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                minHeight: 10,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              // End exercise
                              _endExercise();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("END EXERCISE"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final Paint jointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 8.0
      ..color = Colors.red;

    for (final pose in poses) {
      // Define important landmarks for our exercises
      final essentialLandmarks = [
        // Key reference point
        PoseLandmarkType.nose,

        // Upper body (important for all 3 exercises)
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.rightWrist,

        // Torso/core (important for all 3 exercises)
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,

        // Lower body (important mainly for squats)
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.rightAnkle,
      ];

      // Only draw important connections
      // Upper body
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, scaleX, scaleY);

      // Torso
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, scaleX, scaleY);

      // Lower body (for squats)
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, scaleX, scaleY);
      _drawConnection(canvas, paint, pose, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, scaleX, scaleY);

      // Draw only essential landmarks
      essentialLandmarks.forEach((type) {
        final landmark = pose.landmarks[type];
        if (landmark != null) {
          canvas.drawCircle(
            Offset(landmark.x * scaleX, landmark.y * scaleY),
            6,
            jointPaint,
          );
        }
      });
    }
  }

  void _drawConnection(
      Canvas canvas,
      Paint paint,
      Pose pose,
      PoseLandmarkType startType,
      PoseLandmarkType endType,
      double scaleX,
      double scaleY,
      ) {
    final startLandmark = pose.landmarks[startType];
    final endLandmark = pose.landmarks[endType];

    if (startLandmark == null || endLandmark == null) return;

    canvas.drawLine(
      Offset(startLandmark.x * scaleX, startLandmark.y * scaleY),
      Offset(endLandmark.x * scaleX, endLandmark.y * scaleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}