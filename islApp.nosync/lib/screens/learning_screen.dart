import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sign_letter.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/letter_tile.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SignLetter? _selectedLetter;
  String? _quizLetter;
  List<String> _quizOptions = [];
  int _quizCorrectIndex = 0;
  bool? _quizAnswered;
  int _selectedOption = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateQuizQuestion() {
    final random = Random();
    final letters = SignLetter.alphabet;
    final questionLetter = letters[random.nextInt(letters.length)];

    final options = <String>[questionLetter.letter];
    while (options.length < 4) {
      final opt = letters[random.nextInt(letters.length)].letter;
      if (!options.contains(opt)) options.add(opt);
    }
    options.shuffle();

    setState(() {
      _quizLetter = questionLetter.letter;
      _quizOptions = options;
      _quizCorrectIndex = options.indexOf(questionLetter.letter);
      _quizAnswered = null;
      _selectedOption = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlphabetTab(context),
                _buildQuizTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppGradients.accent.createShader(bounds),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            'Learn ISL',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              final quizScores = provider.analyticsService.quizScores;
              final avg = quizScores.isEmpty
                  ? 0
                  : quizScores.reduce((a, b) => a + b) ~/ quizScores.length;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Avg: $avg%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.glassDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassDarkBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textTertiaryDark,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'ISL Alphabet'),
          Tab(text: 'Quiz Mode'),
        ],
      ),
    );
  }

  Widget _buildAlphabetTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedLetter != null) ...[
            _buildLetterDetail(context),
            const SizedBox(height: 16),
          ],
          Text(
            'ISL Alphabet Reference',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a letter to see the hand gesture description',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: SignLetter.alphabet.length,
            itemBuilder: (context, index) {
              final letter = SignLetter.alphabet[index];
              return LetterTile(
                letter: letter.letter,
                description: letter.description,
                isSelected: _selectedLetter?.letter == letter.letter,
                onTap: () => setState(() => _selectedLetter = letter),
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLetterDetail(BuildContext context) {
    final letter = _selectedLetter!;
    return GlassCard(
      gradient: AppGradients.cardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    letter.letter,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter ${letter.letter}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      letter.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedLetter = null),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryTeal.withAlpha(51)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 Hint: ${letter.hint}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Quiz stats
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.confidenceHigh, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.quizScore}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.confidenceHigh),
                          ),
                          Text('Correct',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.quiz_rounded,
                              color: AppColors.accentOrange, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            '${provider.quizTotal}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.accentOrange),
                          ),
                          Text('Total',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.percent_rounded,
                              color: AppColors.primaryTeal, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            provider.quizTotal == 0
                                ? '0%'
                                : '${(provider.quizScore / provider.quizTotal * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.primaryTeal),
                          ),
                          Text('Accuracy',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_quizLetter == null) ...[
                // Start quiz
                GlassCard(
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppGradients.accent.createShader(bounds),
                        child: const Icon(Icons.quiz_rounded,
                            size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ISL Quiz Mode',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Test your knowledge of Indian Sign Language alphabet!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: 'Start Quiz',
                        icon: Icons.play_arrow_rounded,
                        gradient: AppGradients.accent,
                        onPressed: () {
                          provider.resetQuiz();
                          _generateQuizQuestion();
                        },
                        width: 200,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Quiz question
                _buildQuizQuestion(context, provider),
              ],
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuizQuestion(BuildContext context, AppProvider provider) {
    final letterData = SignLetter.alphabet.firstWhere(
      (l) => l.letter == _quizLetter,
    );

    return GlassCard(
      child: Column(
        children: [
          Text(
            'Which letter is this?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppGradients.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassDarkBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.sign_language,
                    size: 48, color: AppColors.primaryTeal),
                const SizedBox(height: 12),
                Text(
                  letterData.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  letterData.hint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryTeal,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            _quizOptions.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _quizAnswered != null
                    ? null
                    : () {
                        setState(() {
                          _selectedOption = index;
                          _quizAnswered =
                              index == _quizCorrectIndex;
                          provider.answerQuiz(_quizAnswered!);
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: _getOptionGradient(index),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _getOptionBorderColor(index),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _quizOptions[index],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _getOptionTextColor(index),
                        ),
                      ),
                      const Spacer(),
                      if (_quizAnswered != null && index == _quizCorrectIndex)
                        const Icon(Icons.check_circle,
                            color: AppColors.confidenceHigh),
                      if (_quizAnswered != null &&
                          index == _selectedOption &&
                          index != _quizCorrectIndex)
                        const Icon(Icons.cancel, color: AppColors.error),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_quizAnswered != null)
            GradientButton(
              text: 'Next Question',
              icon: Icons.arrow_forward_rounded,
              onPressed: _generateQuizQuestion,
              width: 200,
            ),
        ],
      ),
    );
  }

  Gradient? _getOptionGradient(int index) {
    if (_quizAnswered == null) return null;
    if (index == _quizCorrectIndex) {
      return LinearGradient(
        colors: [
          AppColors.confidenceHigh.withAlpha(26),
          AppColors.confidenceHigh.withAlpha(13),
        ],
      );
    }
    if (index == _selectedOption && index != _quizCorrectIndex) {
      return LinearGradient(
        colors: [
          AppColors.error.withAlpha(26),
          AppColors.error.withAlpha(13),
        ],
      );
    }
    return null;
  }

  Color _getOptionBorderColor(int index) {
    if (_quizAnswered == null) return AppColors.glassDarkBorder;
    if (index == _quizCorrectIndex) return AppColors.confidenceHigh;
    if (index == _selectedOption) return AppColors.error;
    return AppColors.glassDarkBorder;
  }

  Color _getOptionTextColor(int index) {
    if (_quizAnswered == null) return AppColors.textPrimaryDark;
    if (index == _quizCorrectIndex) return AppColors.confidenceHigh;
    if (index == _selectedOption) return AppColors.error;
    return AppColors.textTertiaryDark;
  }
}
