class WordBuilder {
  final List<String> _letters = [];
  final List<String> _words = [];
  String _currentWord = '';

  // Simple dictionary for suggestions
  static const List<String> _dictionary = [
    'HELLO', 'HELP', 'THANKS', 'PLEASE', 'SORRY', 'YES', 'NO',
    'GOOD', 'BAD', 'MORNING', 'NIGHT', 'FRIEND', 'FAMILY',
    'WATER', 'FOOD', 'HOME', 'SCHOOL', 'WORK', 'NAME', 'HOW',
    'WHAT', 'WHERE', 'WHEN', 'WHY', 'WHO', 'WELCOME', 'INDIA',
    'LOVE', 'HAPPY', 'STOP', 'GO', 'COME', 'LEARN', 'SIGN',
    'LANGUAGE', 'THANK', 'YOU', 'NEED', 'WANT', 'LIKE',
  ];

  void addLetter(String letter) {
    _letters.add(letter);
    _currentWord += letter;
  }

  void addSpace() {
    if (_currentWord.isNotEmpty) {
      _words.add(_currentWord);
      _currentWord = '';
    }
  }

  void backspace() {
    if (_currentWord.isNotEmpty) {
      _currentWord = _currentWord.substring(0, _currentWord.length - 1);
    } else if (_words.isNotEmpty) {
      _currentWord = _words.removeLast();
    }
    if (_letters.isNotEmpty) {
      _letters.removeLast();
    }
  }

  void clear() {
    _letters.clear();
    _words.clear();
    _currentWord = '';
  }

  String get currentWord => _currentWord;

  String get fullText {
    final parts = [..._words];
    if (_currentWord.isNotEmpty) parts.add(_currentWord);
    return parts.join(' ');
  }

  List<String> get words => List.unmodifiable(_words);

  /// Get spelling suggestions for current word
  List<String> getSuggestions() {
    if (_currentWord.length < 2) return [];

    final suggestions = <String>[];
    for (final word in _dictionary) {
      if (word.startsWith(_currentWord) && word != _currentWord) {
        suggestions.add(word);
      }
    }

    // Also find close matches (simple edit distance)
    if (suggestions.isEmpty && _currentWord.length >= 3) {
      for (final word in _dictionary) {
        if (_isCloseMatch(_currentWord, word)) {
          suggestions.add(word);
        }
      }
    }

    return suggestions.take(5).toList();
  }

  /// Get spell correction for completed word
  String? getCorrection(String word) {
    if (_dictionary.contains(word)) return null;

    for (final dictWord in _dictionary) {
      if (_isCloseMatch(word, dictWord)) {
        return dictWord;
      }
    }
    return null;
  }

  /// Simple close-match check (max 1 character difference)
  bool _isCloseMatch(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;

    int differences = 0;
    final minLen = a.length < b.length ? a.length : b.length;

    for (int i = 0; i < minLen; i++) {
      if (a[i] != b[i]) differences++;
      if (differences > 1) return false;
    }

    return differences + (a.length - b.length).abs() <= 1;
  }

  /// Predict next possible words based on context
  List<String> predictNextWords() {
    if (_words.isEmpty) {
      return ['HELLO', 'PLEASE', 'HELP', 'THANKS', 'HOW'];
    }

    final lastWord = _words.last;
    // Simple bigram predictions
    final predictions = <String, List<String>>{
      'HELLO': ['HOW', 'FRIEND', 'GOOD'],
      'GOOD': ['MORNING', 'NIGHT'],
      'THANK': ['YOU'],
      'HOW': ['ARE', 'YOU'],
      'I': ['NEED', 'WANT', 'LIKE', 'LOVE'],
      'PLEASE': ['HELP', 'COME', 'STOP'],
      'MY': ['NAME', 'HOME', 'FAMILY', 'FRIEND'],
    };

    return predictions[lastWord] ?? ['PLEASE', 'THANKS', 'HELP'];
  }
}
