import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/exercise_model.dart';
import '../../../models/exercise_option_model.dart';

class ExerciseQuestionScreen extends StatefulWidget {
  final int exerciseId=1;

  const ExerciseQuestionScreen({super.key});

  @override
  State<ExerciseQuestionScreen> createState() => _ExerciseQuestionScreenState();
}

class _ExerciseQuestionScreenState extends State<ExerciseQuestionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ExerciseModel? exercise;

  /*
      'multiple_choice_single_answer'     => 'Single Answer',
      'multiple_choice_multiple_answer'   => 'Multiple Answer',
      'fill_the_blank'                     => 'Fill in the blank',
      'true_false_answer'                 => 'True / False',
   */
  List<int> selectedOptions = [];

  @override
  void initState() {
    super.initState();

    // Fetch API ...
    // final ExerciseModel exercise = await GetExerciseFromAPI(widget.exerciseId);

    // API'den veri çekilmesi varsayımı
    if (widget.exerciseId == 1) {
      exercise = ExerciseModel(
          id: widget.exerciseId,
          title: 'What is the capital of France?',
          type: 'multiple_choice_single_answer',
          typeName: 'Single Answer',
          options: [
            ExerciseOptionModel(id: 1, title: 'Paris', isCorrect: true),
            ExerciseOptionModel(id: 2, title: 'London', isCorrect: false),
            ExerciseOptionModel(id: 3, title: 'Berlin', isCorrect: false),
            ExerciseOptionModel(id: 4, title: 'Istanbul', isCorrect: false),
          ]);
    } else if (widget.exerciseId == 2) {
      exercise = ExerciseModel(
          id: widget.exerciseId,
          title: 'Select the continents',
          type: 'multiple_choice_multiple_answer',
          typeName: 'Multiple Answer',
          options: [
            ExerciseOptionModel(id: 1, title: 'Asia', isCorrect: true),
            ExerciseOptionModel(id: 2, title: 'Europe', isCorrect: false),
            ExerciseOptionModel(id: 3, title: 'Australia', isCorrect: true),
            ExerciseOptionModel(id: 4, title: 'Africa', isCorrect: false),
          ]);
    } else if (widget.exerciseId == 3) {
      exercise = ExerciseModel(
          id: widget.exerciseId,
          title: 'What is the _______ largest ocean?',
          type: 'fill_the_blank',
          typeName: 'Fill in the blank',
          options: [
            ExerciseOptionModel(id: 1, title: 'Pacific', isCorrect: false),
            ExerciseOptionModel(id: 2, title: 'Atlantic', isCorrect: true),
            ExerciseOptionModel(id: 3, title: 'Indian', isCorrect: false),
            ExerciseOptionModel(id: 4, title: 'Arctic', isCorrect: false),
          ]);
    } else if (widget.exerciseId == 4) {
      exercise = ExerciseModel(
          id: widget.exerciseId,
          title: 'The capital of Türkiye is Ankara.',
          type: 'true_false_answer',
          typeName: 'True / False',
          options: [
            ExerciseOptionModel(id: 1, title: 'True', isCorrect: true),
            ExerciseOptionModel(id: 2, title: 'False', isCorrect: false),
          ]);
    }
  }

  void toggleOption(int id) {
    setState(() {
      if (exercise!.type == 'multiple_choice_multiple_answer') {
        if (selectedOptions.contains(id)) {
          selectedOptions.remove(id);
        } else {
          selectedOptions.add(id);
        }
      } else {
        selectedOptions = [id];
      }
    });
  }

  void validateAnswers() {
    bool isCorrect;
    if (exercise!.type == 'multiple_choice_multiple_answer') {
      isCorrect = selectedOptions.every((optionId) =>
              exercise!.options.where((option) => option.isCorrect).map((option) => option.id).contains(optionId)) &&
          selectedOptions.length == exercise!.options.where((option) => option.isCorrect).length;
    } else {
      isCorrect = selectedOptions.length == 1 &&
          exercise!.options.firstWhere((option) => option.id == selectedOptions.first).isCorrect;
    }

    if (isCorrect) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Congratulations!',
        text: 'You answered correctly!',
        confirmBtnText: "Okay",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      );
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Incorrect!',
        text: 'You answered wrong!',
        confirmBtnText: "Okay",
        showCancelBtn: false,
      );
    }
  }

  Widget buildOptionButton(ExerciseOptionModel option) {
    final isSelected = selectedOptions.contains(option.id);
    return GestureDetector(
      onTap: () => toggleOption(option.id),
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
            option.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget getExerciseTypeText() {
    switch (exercise!.type) {
      case "multiple_choice_single_answer":
        return topText("Choose the correct option the question below");

      case "multiple_choice_multiple_answer":
        return topText("Select all the correct options");

      case "fill_the_blank":
        return topText("Fill in the blank with the appropriate term");

      case "true_false_answer":
        return topText("Determine the correctness of the following statement");

      default:
        return const SizedBox();
    }
  }

  AutoSizeText topText(String text) => AutoSizeText(
        maxLines: 1,
        text,
        style: TextStyle(
          fontSize: 15,
          color: const Color.fromRGBO(0, 100, 0, 1),
        ),
        minFontSize: 15,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(31, 31, 57, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Question Screen",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(31, 31, 57, 1),
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            getExerciseTypeText(),
            const SizedBox(
              height: 20,
            ),
            Text(
              exercise?.title ?? '',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...exercise?.options.map(buildOptionButton).toList() ?? [],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: validateAnswers,
              child: Text(
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
