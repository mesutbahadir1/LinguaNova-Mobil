// Öncelikle, progress verisi için bir model sınıfı oluşturalım
// Bu sınıfı models klasörüne ekleyebilirsiniz (models/user_progress_model.dart)

class UserProgressModel {
  final String title;
  final int completedActivityCount;
  final int totalActivityCount;

  UserProgressModel({
    required this.title,
    required this.completedActivityCount,
    required this.totalActivityCount,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      title: json['title'],
      completedActivityCount: json['completedCount'],
      totalActivityCount: json['totalCount'],
    );
  }
}

class UserProgressResponse {
  final UserProgressModel articleProgress;
  final UserProgressModel audioProgress;
  final UserProgressModel videoProgress;

  UserProgressResponse({
    required this.articleProgress,
    required this.audioProgress,
    required this.videoProgress,
  });

  factory UserProgressResponse.fromJson(Map<String, dynamic> json) {
    return UserProgressResponse(
      articleProgress: UserProgressModel.fromJson(json['articleProgress']),
      audioProgress: UserProgressModel.fromJson(json['audioProgress']),
      videoProgress: UserProgressModel.fromJson(json['videoProgress']),
    );
  }
}