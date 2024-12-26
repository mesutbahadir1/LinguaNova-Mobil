import 'exercise_option_model.dart';

class ExerciseModel {
  final int id;
  final String title;
  final String type;
  final String typeName;
  final List<ExerciseOptionModel> options;

  ExerciseModel({
    required this.id,
    required this.title,
    required this.type,
    required this.typeName,
    required this.options,
  });
}
