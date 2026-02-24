import 'package:flutter/material.dart';
import '../services/analytics_service.dart';
import '../services/word_builder.dart';
import '../services/tts_service.dart';

class AppProvider extends ChangeNotifier {
  // Theme
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Navigation
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Translation state
  bool _isTranslating = false;
  bool get isTranslating => _isTranslating;

  String _currentLetter = '';
  String get currentLetter => _currentLetter;

  double _confidence = 0.0;
  double get confidence => _confidence;

  double _stability = 0.0;
  double get stability => _stability;

  bool _isStable = false;
  bool get isStable => _isStable;

  final WordBuilder wordBuilder = WordBuilder();
  final TtsService ttsService = TtsService();
  final AnalyticsService analyticsService = AnalyticsService();

  final List<String> _detectedHistory = [];
  List<String> get detectedHistory => _detectedHistory;

  // Translation methods
  void startTranslation() {
    _isTranslating = true;
    notifyListeners();
  }

  void stopTranslation() {
    _isTranslating = false;
    notifyListeners();
  }

  void updateDetection(String letter, double conf, double stab, bool stable) {
    _currentLetter = letter;
    _confidence = conf;
    _stability = stab;
    _isStable = stable;
    notifyListeners();
  }

  void confirmLetter(String letter) {
    wordBuilder.addLetter(letter);
    _detectedHistory.add(letter);
    analyticsService.recordDetection(correct: true);
    notifyListeners();
  }

  void addSpace() {
    wordBuilder.addSpace();
    analyticsService.recordWord();
    notifyListeners();
  }

  void clearText() {
    wordBuilder.clear();
    _detectedHistory.clear();
    notifyListeners();
  }

  void backspace() {
    wordBuilder.backspace();
    if (_detectedHistory.isNotEmpty) {
      _detectedHistory.removeLast();
    }
    notifyListeners();
  }

  Future<void> speakText() async {
    final text = wordBuilder.fullText;
    if (text.isNotEmpty) {
      await ttsService.speak(text);
    }
  }

  // Quiz state
  int _quizScore = 0;
  int get quizScore => _quizScore;

  int _quizTotal = 0;
  int get quizTotal => _quizTotal;

  void resetQuiz() {
    _quizScore = 0;
    _quizTotal = 0;
    notifyListeners();
  }

  void answerQuiz(bool correct) {
    _quizTotal++;
    if (correct) _quizScore++;
    notifyListeners();
  }

  // Font size for accessibility
  double _fontScale = 1.0;
  double get fontScale => _fontScale;

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }

  // Offline mode indicator
  bool _isOfflineMode = true;
  bool get isOfflineMode => _isOfflineMode;

  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }

  Future<void> initialize() async {
    await analyticsService.initialize();
    await ttsService.initialize();
    await analyticsService.generateDemoData();
    notifyListeners();
  }

  @override
  void dispose() {
    ttsService.dispose();
    super.dispose();
  }
}
