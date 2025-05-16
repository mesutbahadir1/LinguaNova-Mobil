import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/constants/app_config.dart';
import '../../../models/exercise_list_model.dart';
import 'quiz_result_screen.dart';

class QuizFlowScreen extends StatefulWidget {
  final int itemId;
  final int type; // 1 = Article, 2 = Video, 3 = Audio
  final String contentTitle; // Title of the article/video/audio

  const QuizFlowScreen({
    super.key,
    required this.itemId,
    required this.type,
    required this.contentTitle,
  });

  @override
  State<QuizFlowScreen> createState() => _QuizFlowScreenState();
}

class _QuizFlowScreenState extends State<QuizFlowScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Quiz state
  List<ExerciseListModel> exercises = [];
  int currentQuestionIndex = 0;
  List<int> selectedAnswers = [];
  List<bool> answerResults = [];
  bool isLoading = true;
  bool quizCompleted = false;
  int? userId;

  // For animated transition between questions
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Pass threshold (e.g., 70%)
  final double passThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchExercises();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadUserIdAndFetchExercises() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('userId');

    if (id != null) {
      setState(() {
        userId = id;
      });
      await fetchExercises();
      setState(() {
        isLoading = false;
        // Initialize selectedAnswers list with -1 values (no selection)
        selectedAnswers = List.filled(exercises.length, -1);
        answerResults = List.filled(exercises.length, false);
      });
    } else {
      // Handle case where userId is not available
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchExercises() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);

    String url = '';
    switch (widget.type) {
      case 1: // Article
        url = '${HTTPS_URL}/api/UserTestProgress/ArticleTests/${userId}/${widget.itemId}';
        break;
      case 2: // Video
        url = '${HTTPS_URL}/api/UserTestProgress/VideoTests/${userId}/${widget.itemId}';
        break;
      case 3: // Audio
        url = '${HTTPS_URL}/api/UserTestProgress/AudioTests/${userId}/${widget.itemId}';
        break;
      default:
        throw Exception("Invalid type provided");
    }

    try {
      final response = await ioClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          exercises = data.map((item) => ExerciseListModel.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load exercises for type ${widget.type}');
      }
    } catch (e) {
      print("Error fetching exercises: $e");
      // Handle error state
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateIsCorrectStatus(int? testProgressId, bool isCorrect) async {
    if (testProgressId == null) {
      return;
    }

    final String url = "${HTTPS_URL}/api/UserTestProgress/UpdateIsCorrect/$testProgressId?type=${widget.type}";
    HttpClient client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(client);

    try {
      final response = await ioClient.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isCorrect': isCorrect}),
      );

      if (response.statusCode == 204) {
        print("Test progress updated successfully");
      } else if (response.headers.containsKey('location')) {
        // If there's a redirect, follow it
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          final redirectedResponse = await ioClient.put(
            Uri.parse(newUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'isCorrect': isCorrect}),
          );
          if (redirectedResponse.statusCode == 204) {
            print("Test progress updated successfully after redirect");
          } else {
            print("Failed after redirect: ${redirectedResponse.body}");
          }
        }
      } else {
        print("Failed to update test progress: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void selectAnswer(int answerIndex) {
    if (quizCompleted) return;

    setState(() {
      selectedAnswers[currentQuestionIndex] = answerIndex;
    });
  }

  Future<void> submitAnswer() async {
    if (selectedAnswers[currentQuestionIndex] == -1) {
      // Show warning if no answer is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an answer"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final currentExercise = exercises[currentQuestionIndex];
    final isCorrect = selectedAnswers[currentQuestionIndex] == currentExercise.correctAnswerIndex;

    // Store result
    setState(() {
      answerResults[currentQuestionIndex] = isCorrect;
    });

    // Update backend
    await updateIsCorrectStatus(currentExercise.testProgressId, isCorrect);

    if (currentQuestionIndex < exercises.length - 1) {
      // Move to next question with animation
      _animationController.reverse().then((_) {
        setState(() {
          currentQuestionIndex++;
        });
        _animationController.forward();
      });
    } else {
      // End of quiz
      finishQuiz();
    }
  }

  void finishQuiz() {
    setState(() {
      quizCompleted = true;
    });

    final correctAnswersCount = answerResults.where((result) => result).length;
    final totalQuestions = exercises.length;

    // Navigate to the result screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          correctAnswers: correctAnswersCount,
          totalQuestions: totalQuestions,
          passThreshold: passThreshold,
          onRetry: () {
            Navigator.of(context).pop(); // Close result screen
            // Reset quiz state
            setState(() {
              currentQuestionIndex = 0;
              selectedAnswers = List.filled(exercises.length, -1);
              answerResults = List.filled(exercises.length, false);
              quizCompleted = false;
              _animationController.reset();
              _animationController.forward();
            });
          },
          onComplete: () {
            Navigator.of(context).pop(); // Close result screen
            Navigator.of(context).pop(); // Return to content screen
          },
        ),
      ),
    );
  }

  Widget buildOptionButton(String answer, int index) {
    final selected = selectedAnswers[currentQuestionIndex] == index;

    return GestureDetector(
      onTap: () => selectAnswer(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(0, 181, 80, 1)
              : const Color.fromRGBO(47, 47, 66, 1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.green : const Color(0xFFD3D3D3),
            width: selected ? 2.0 : 0.7,
          ),
        ),
        child: Center(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgressIndicator() {
    final progress = (currentQuestionIndex + 1) / exercises.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${currentQuestionIndex + 1}/${exercises.length}",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget buildQuizContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Text(
          "No questions available",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final currentExercise = exercises[currentQuestionIndex];

    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(_animation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProgressIndicator(),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(47, 47, 66, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFD3D3D3), width: 0.7),
              ),
              child: Text(
                currentExercise.question,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            buildOptionButton(currentExercise.answer1, 1),
            buildOptionButton(currentExercise.answer2, 2),
            buildOptionButton(currentExercise.answer3, 3),
            buildOptionButton(currentExercise.answer4, 4),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Submit Answer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.contentTitle,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildQuizContent(),
        ),
      ),
    );
  }
}