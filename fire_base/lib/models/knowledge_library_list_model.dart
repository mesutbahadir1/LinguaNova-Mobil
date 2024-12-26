class KnowledgeLibraryListModel {
  final int id;
  final String title;
  final String imageUrl;
  final String knowledgeType;
  final bool isComplete;

  KnowledgeLibraryListModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.knowledgeType,
    required this.isComplete,
  });
}
