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
import '../../../models/content_models.dart';
import '../../widgets/level_up_animation.dart';
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

      if (response.statusCode == 200) {
        // Parse the new response format
        final responseData = jsonDecode(response.body);
        final updateResponse = UpdateTestResponseDto.fromJson(responseData);
        
        print("Test progress updated successfully");
        print("Level up: ${updateResponse.levelUp}");
        print("New level: ${updateResponse.newLevel}");
        
        // Check if level up occurred
        if (updateResponse.levelUp && updateResponse.newLevel != null) {
          await _showLevelUpAnimation(updateResponse.newLevel!);
        }
        
      } else if (response.statusCode == 204) {
        // Handle old format for backward compatibility
        print("Test progress updated successfully (old format)");
      } else if (response.headers.containsKey('location')) {
        // If there's a redirect, follow it
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          final redirectedResponse = await ioClient.put(
            Uri.parse(newUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'isCorrect': isCorrect}),
          );
          
          if (redirectedResponse.statusCode == 200) {
            final responseData = jsonDecode(redirectedResponse.body);
            final updateResponse = UpdateTestResponseDto.fromJson(responseData);
            
            print("Test progress updated successfully after redirect");
            
            if (updateResponse.levelUp && updateResponse.newLevel != null) {
              await _showLevelUpAnimation(updateResponse.newLevel!);
            }
          } else if (redirectedResponse.statusCode == 204) {
            print("Test progress updated successfully after redirect (old format)");
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

  Future<void> _showLevelUpAnimation(int newLevel) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpAnimationDialog(
        newLevel: newLevel,
        onComplete: () {
          // Level up animasyonu tamamlandıktan sonra yapılacak işlemler
          print("Level up animation completed for level: $newLevel");
        },
      ),
    );
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.purple.withOpacity(0.3)
              : const Color.fromRGBO(47, 47, 66, 1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.purple : Colors.purple.withOpacity(0.3),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: selected ? Colors.purple.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              blurRadius: selected ? 8 : 4,
              spreadRadius: selected ? 1 : 0,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: selected
              ? LinearGradient(
                  colors: [
                    const Color.fromRGBO(47, 47, 66, 1),
                    Colors.purple.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.purple : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.purple : Colors.purple.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Center(
                      child: Text(
                        String.fromCharCode(index + 65), // A, B, C, D
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.purple.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Answer text
            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressIndicator() {
    final progress = (currentQuestionIndex + 1) / exercises.length;
    final formattedProgress = (progress * 100).toInt();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Question counter with badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 47, 66, 1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.quiz, color: Colors.purple.withOpacity(0.7), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Question ${currentQuestionIndex + 1}/${exercises.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress percentage with circular indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 47, 66, 1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          formattedProgress > 50 ? Colors.greenAccent : Colors.purpleAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$formattedProgress%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Linear progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                formattedProgress > 50 ? Colors.greenAccent : Colors.purpleAccent,
              ),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuizContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.purpleAccent,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading questions...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 50),
            const SizedBox(height: 16),
            const Text(
              "No questions available",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please try again later",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildProgressIndicator(),
                  const SizedBox(height: 24),
                  
                  // Question card with enhanced styling
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromRGBO(55, 55, 80, 1),
                              const Color.fromRGBO(47, 47, 66, 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question label
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                "QUESTION",
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Question text
                            Text(
                              currentExercise.question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Decorative elements
                      Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.help_outline,
                              color: Colors.purple.withOpacity(0.7),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  // Instructions text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Text(
                      "Select the correct answer:",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  // Answer options
                  buildOptionButton(currentExercise.answer1, 0),
                  buildOptionButton(currentExercise.answer2, 1),
                  buildOptionButton(currentExercise.answer3, 2),
                  buildOptionButton(currentExercise.answer4, 3),
                  const SizedBox(height: 32),
                  
                  // Submit button with enhanced styling
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade700, Colors.purple.shade500],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Submit Answer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Quiz: ${widget.contentTitle}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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