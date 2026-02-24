class QuizQuestion {
  final String letter;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.letter,
    required this.options,
    required this.correctIndex,
  });

  String get correctAnswer => options[correctIndex];
}
