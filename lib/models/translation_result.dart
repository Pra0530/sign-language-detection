class TranslationResult {
  final String letter;
  final double confidence;
  final DateTime timestamp;
  final bool isStable;
  final Duration stabilityDuration;

  const TranslationResult({
    required this.letter,
    required this.confidence,
    required this.timestamp,
    this.isStable = false,
    this.stabilityDuration = Duration.zero,
  });

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.5) return 'Medium';
    return 'Low';
  }
}
