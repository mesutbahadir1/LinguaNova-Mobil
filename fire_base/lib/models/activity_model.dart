class ActivityModel {
  final int id;
  final String title;
  final int completedActivityCount;
  final int totalActivityCount;

  ActivityModel({
    required this.id,
    required this.title,
    required this.completedActivityCount,
    required this.totalActivityCount,
  });
}
