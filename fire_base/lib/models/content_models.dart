// İçerik türleri için model sınıfları
class ArticleModel {
  final int id;
  final String title;
  final String content;
  final bool isCompleted;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class VideoModel {
  final int id;
  final String title;
  final String url;
  final bool isCompleted;

  VideoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.isCompleted,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class AudioModel {
  final int id;
  final String title;
  final String url;
  final bool isCompleted;

  AudioModel({
    required this.id,
    required this.title,
    required this.url,
    required this.isCompleted,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

// Quiz sorularını temsil eden model sınıfları
class QuizQuestionModel {
  final int id;
  final String question;
  final String answer1;
  final String answer2;
  final String answer3;
  final String answer4;
  final int correctAnswerIndex;
  final int? testProgressId;
  final bool isCorrect;

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.answer1,
    required this.answer2,
    required this.answer3,
    required this.answer4,
    required this.correctAnswerIndex,
    this.testProgressId,
    required this.isCorrect,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer1: json['answer1'] ?? '',
      answer2: json['answer2'] ?? '',
      answer3: json['answer3'] ?? '',
      answer4: json['answer4'] ?? '',
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      testProgressId: json['testProgressId'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}

// UserProgress için model
class UserProgressModel {
  final int id;
  final bool isCompleted;

  UserProgressModel({
    required this.id,
    required this.isCompleted,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

// API Response Modelleri
class ArticleProgressDto {
  final int id;
  final String title;
  final String content;
  final bool isCompleted;

  ArticleProgressDto({
    required this.id,
    required this.title,
    required this.content,
    required this.isCompleted,
  });

  factory ArticleProgressDto.fromJson(Map<String, dynamic> json) {
    return ArticleProgressDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class VideoProgressDto {
  final int id;
  final String title;
  final String url;
  final bool isCompleted;

  VideoProgressDto({
    required this.id,
    required this.title,
    required this.url,
    required this.isCompleted,
  });

  factory VideoProgressDto.fromJson(Map<String, dynamic> json) {
    return VideoProgressDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class AudioProgressDto {
  final int id;
  final String title;
  final String url;
  final bool isCompleted;

  AudioProgressDto({
    required this.id,
    required this.title,
    required this.url,
    required this.isCompleted,
  });

  factory AudioProgressDto.fromJson(Map<String, dynamic> json) {
    return AudioProgressDto(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 