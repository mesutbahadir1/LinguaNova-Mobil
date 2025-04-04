class ExerciseListModel {
  final int exerciseId;
  final String question;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final int correctAnswerIndex;
  final int? testProgressId;
  final bool isCorrect;

  ExerciseListModel({
    required this.exerciseId,
    required this.question,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswerIndex,
    required this.testProgressId,
    required this.isCorrect,
  });

  // JSON verisini `ExerciseListModel`'e dönüştürmek için bir fabrika metodu
  factory ExerciseListModel.fromJson(Map<String, dynamic> json) {
    return ExerciseListModel(
      exerciseId: json['id'],
      question: json['question'],
      answer1: json['answer1'],
      answer2: json['answer2'],
      answer3: json['answer3'],
      answer4: json['answer4'],
      correctAnswerIndex: json['correctAnswerIndex'],
      testProgressId: json['testProgressId'],
      isCorrect: json['isCorrect'],
    );
  }
}
