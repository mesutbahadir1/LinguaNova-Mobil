import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../app/constants/app_config.dart';
import '../../../models/exercise_list_model.dart';

class ExerciseQuestionScreen extends StatefulWidget {
  final ExerciseListModel exercise;
  final int type;

  const ExerciseQuestionScreen({super.key, required this.exercise, required this.type});

  @override
  State<ExerciseQuestionScreen> createState() => _ExerciseQuestionScreenState();
}

class _ExerciseQuestionScreenState extends State<ExerciseQuestionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<int> selectedOptions = [];

  void toggleOption(int index) {
    setState(() {
      selectedOptions = [index];
    });
  }

  Future<void> updateIsCorrectStatus(int? testProgressId, bool isCorrect) async {
    if (testProgressId == null) {
      print(widget.exercise.answer1);
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
        // Eğer yönlendirme varsa yeni URL'ye tekrar istek yap
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

  void validateAnswers() {
    bool isCorrect = selectedOptions.isNotEmpty && selectedOptions.first == widget.exercise.correctAnswerIndex;

    if (isCorrect) {
      updateIsCorrectStatus(widget.exercise.testProgressId, true);
    }

    QuickAlert.show(
      context: context,
      type: isCorrect ? QuickAlertType.success : QuickAlertType.error,
      title: isCorrect ? 'Congratulations!' : 'Incorrect!',
      text: isCorrect ? 'You answered correctly!' : 'You answered wrong!',
      confirmBtnText: "Okay",
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        Navigator.pop(context);
        setState(() {
        });
      },
    );
  }

  Widget buildOptionButton(String answer, int index) {
    final isSelected = selectedOptions.contains(index);
    return GestureDetector(
      onTap: () => toggleOption(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(0, 181, 80, 1)
              : Theme.of(context).brightness == Brightness.light
              ? const Color.fromRGBO(220, 220, 220, 1)
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFD3D3D3),
            width: 0.7,
          ),
        ),
        child: Center(
          child: Text(
            answer,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  AutoSizeText topText(String text) => AutoSizeText(
    maxLines: 1,
    text,
    style: const TextStyle(
      fontSize: 15,
      color: Color.fromRGBO(0, 100, 0, 1),
    ),
    minFontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Question Screen",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            topText("Choose the correct option for the question below"),
            const SizedBox(height: 20),
            Text(
              widget.exercise.question,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            buildOptionButton(widget.exercise.answer1, 1),
            buildOptionButton(widget.exercise.answer2, 2),
            buildOptionButton(widget.exercise.answer3, 3),
            buildOptionButton(widget.exercise.answer4, 4),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: validateAnswers,
              child: const Text(
                'Validate',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}