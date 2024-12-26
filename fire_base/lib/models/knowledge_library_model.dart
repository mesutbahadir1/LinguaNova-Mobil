class KnowledgeLibraryModel {
  final int id;
  final String title;
  final String imageUrl;
  final String knowledgeType;
  final List<String> contents;

  KnowledgeLibraryModel(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.knowledgeType,
      required this.contents});
}
