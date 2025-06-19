class UpdateTestResponseDto {
  final bool levelUp;
  final int? newLevel;
  final bool isCorrect;

  UpdateTestResponseDto({
    required this.levelUp,
    this.newLevel,
    required this.isCorrect,
  });

  factory UpdateTestResponseDto.fromJson(Map<String, dynamic> json) {
    return UpdateTestResponseDto(
      levelUp: json['levelUp'] ?? false,
      newLevel: json['newLevel'],
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}
