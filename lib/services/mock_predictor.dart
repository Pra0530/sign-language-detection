import 'dart:math';
import '../models/translation_result.dart';

class MockPredictor {
  final Random _random = Random();
  String? _lastLetter;
  DateTime? _stabilityStart;
  static const Duration stabilityThreshold = Duration(seconds: 1);

  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  /// Simulates gesture recognition returning a mock result
  TranslationResult predict() {
    // Simulate detecting a letter with some randomness
    final letter = _letters[_random.nextInt(_letters.length)];
    final confidence = 0.5 + _random.nextDouble() * 0.5; // 50-100%

    // Check stability
    bool isStable = false;
    Duration stabilityDuration = Duration.zero;

    if (letter == _lastLetter && _stabilityStart != null) {
      stabilityDuration = DateTime.now().difference(_stabilityStart!);
      isStable = stabilityDuration >= stabilityThreshold;
    } else {
      _lastLetter = letter;
      _stabilityStart = DateTime.now();
    }

    return TranslationResult(
      letter: letter,
      confidence: confidence,
      timestamp: DateTime.now(),
      isStable: isStable,
      stabilityDuration: stabilityDuration,
    );
  }

  void reset() {
    _lastLetter = null;
    _stabilityStart = null;
  }
}
