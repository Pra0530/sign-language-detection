import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _keyTotalSessions = 'total_sessions';
  static const String _keyTotalLetters = 'total_letters';
  static const String _keyTotalWords = 'total_words';
  static const String _keyCorrectDetections = 'correct_detections';
  static const String _keyTotalDetections = 'total_detections';
  static const String _keyMistakenLetters = 'mistaken_letters';
  static const String _keyQuizScores = 'quiz_scores';
  static const String _keyAccuracyHistory = 'accuracy_history';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Session tracking
  int get totalSessions => _prefs?.getInt(_keyTotalSessions) ?? 0;
  int get totalLetters => _prefs?.getInt(_keyTotalLetters) ?? 0;
  int get totalWords => _prefs?.getInt(_keyTotalWords) ?? 0;
  int get correctDetections => _prefs?.getInt(_keyCorrectDetections) ?? 0;
  int get totalDetections => _prefs?.getInt(_keyTotalDetections) ?? 0;

  double get accuracyPercentage {
    if (totalDetections == 0) return 0.0;
    return (correctDetections / totalDetections) * 100;
  }

  Future<void> incrementSessions() async {
    await _prefs?.setInt(_keyTotalSessions, totalSessions + 1);
  }

  Future<void> recordDetection({required bool correct}) async {
    await _prefs?.setInt(_keyTotalDetections, totalDetections + 1);
    if (correct) {
      await _prefs?.setInt(_keyCorrectDetections, correctDetections + 1);
    }
    await _prefs?.setInt(_keyTotalLetters, totalLetters + 1);
  }

  Future<void> recordWord() async {
    await _prefs?.setInt(_keyTotalWords, totalWords + 1);
  }

  // Mistaken letters tracking
  Map<String, int> get mistakenLetters {
    final data = _prefs?.getString(_keyMistakenLetters);
    if (data == null) return {};
    return Map<String, int>.from(json.decode(data));
  }

  Future<void> recordMistake(String letter) async {
    final mistakes = mistakenLetters;
    mistakes[letter] = (mistakes[letter] ?? 0) + 1;
    await _prefs?.setString(_keyMistakenLetters, json.encode(mistakes));
  }

  // Quiz scores
  List<double> get quizScores {
    final data = _prefs?.getString(_keyQuizScores);
    if (data == null) return [];
    return List<double>.from(json.decode(data));
  }

  Future<void> recordQuizScore(double score) async {
    final scores = quizScores;
    scores.add(score);
    if (scores.length > 50) scores.removeAt(0);
    await _prefs?.setString(_keyQuizScores, json.encode(scores));
  }

  // Accuracy history (last 30 sessions)
  List<double> get accuracyHistory {
    final data = _prefs?.getString(_keyAccuracyHistory);
    if (data == null) return [];
    return List<double>.from(json.decode(data));
  }

  Future<void> recordSessionAccuracy(double accuracy) async {
    final history = accuracyHistory;
    history.add(accuracy);
    if (history.length > 30) history.removeAt(0);
    await _prefs?.setString(_keyAccuracyHistory, json.encode(history));
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Generate mock data for demo
  Future<void> generateDemoData() async {
    await _prefs?.setInt(_keyTotalSessions, 47);
    await _prefs?.setInt(_keyTotalLetters, 1253);
    await _prefs?.setInt(_keyTotalWords, 189);
    await _prefs?.setInt(_keyCorrectDetections, 1078);
    await _prefs?.setInt(_keyTotalDetections, 1253);

    final mistakes = {'B': 23, 'D': 18, 'G': 15, 'P': 12, 'Q': 11, 'R': 9, 'N': 8, 'M': 7};
    await _prefs?.setString(_keyMistakenLetters, json.encode(mistakes));

    final history = <double>[
      72, 68, 75, 78, 80, 77, 82, 85, 83, 87,
      84, 88, 86, 90, 89, 91, 88, 92, 90, 93,
      91, 94, 92, 95, 93, 94, 95, 96, 94, 86,
    ];
    await _prefs?.setString(_keyAccuracyHistory, json.encode(history));

    final quizScoresData = <double>[60, 70, 65, 80, 75, 85, 90, 88, 92, 95];
    await _prefs?.setString(_keyQuizScores, json.encode(quizScoresData));
  }
}
