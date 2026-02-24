import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../widgets/glass_card.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/stability_indicator.dart';
import '../widgets/gradient_button.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with TickerProviderStateMixin {
  Timer? _simulationTimer;
  final Random _random = Random();
  final List<String> _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  String _currentLetter = '';
  double _confidence = 0.0;
  double _stability = 0.0;
  bool _isStable = false;
  bool _isRunning = false;
  String? _lastLetter;
  int _holdCount = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    setState(() => _isRunning = true);
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        // Simulate detection with some persistence
        if (_random.nextDouble() > 0.3 && _lastLetter != null) {
          _currentLetter = _lastLetter!;
          _holdCount++;
        } else {
          _currentLetter = _letters[_random.nextInt(_letters.length)];
          if (_currentLetter != _lastLetter) {
            _holdCount = 0;
          }
          _lastLetter = _currentLetter;
        }

        _confidence = 0.5 + _random.nextDouble() * 0.5;
        _stability = (_holdCount / 4.0).clamp(0.0, 1.0);
        _isStable = _holdCount >= 4;

        if (_isStable) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.confirmLetter(_currentLetter);
          _holdCount = 0;
          _lastLetter = null;
        }
      });
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isRunning = false;
      _currentLetter = '';
      _confidence = 0.0;
      _stability = 0.0;
      _isStable = false;
      _holdCount = 0;
      _lastLetter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(context),
            _buildCameraPreview(context),
            _buildDetectionPanel(context),
            _buildWordPanel(context),
            _buildSuggestionsPanel(context),
            const SizedBox(height: 100),
          ],
        ),
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
                AppGradients.primary.createShader(bounds),
            child: const Icon(Icons.sign_language, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            'ISL Translator',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const Spacer(),
          // Offline indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.confidenceHigh.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.confidenceHigh.withAlpha(77)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 14, color: AppColors.confidenceHigh),
                SizedBox(width: 4),
                Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.confidenceHigh,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Camera preview area (simulated)
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgDarkTertiary,
                    AppColors.bgDarkSecondary,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid overlay
                  if (_isRunning) ...[
                    CustomPaint(
                      size: const Size(double.infinity, 280),
                      painter: _GridPainter(),
                    ),
                    // Scanning animation
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return Container(
                          width: 160 + (_pulseController.value * 20),
                          height: 160 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryTeal
                                  .withAlpha((102 + _pulseController.value * 102).toInt()),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  if (!_isRunning)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          size: 48,
                          color: AppColors.textTertiaryDark,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap Start to begin detection',
                          style: TextStyle(
                            color: AppColors.textTertiaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  // Corner markers
                  if (_isRunning) ..._buildCornerMarkers(),
                ],
              ),
            ),
            // Controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientButton(
                    text: _isRunning ? 'Stop' : 'Start Detection',
                    icon: _isRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    gradient:
                        _isRunning ? AppGradients.accent : AppGradients.button,
                    onPressed: () {
                      if (_isRunning) {
                        _stopSimulation();
                      } else {
                        _startSimulation();
                      }
                    },
                    width: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    return [
      Positioned(
        top: 40,
        left: 60,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primaryTeal, width: 3),
              left: BorderSide(color: AppColors.primaryTeal, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        top: 40,
        right: 60,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primaryTeal, width: 3),
              right: BorderSide(color: AppColors.primaryTeal, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 40,
        left: 60,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primaryTeal, width: 3),
              left: BorderSide(color: AppColors.primaryTeal, width: 3),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 40,
        right: 60,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primaryTeal, width: 3),
              right: BorderSide(color: AppColors.primaryTeal, width: 3),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildDetectionPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Stability indicator
          StabilityIndicator(
            progress: _stability,
            isStable: _isStable,
            letter: _currentLetter,
          ),
          const SizedBox(width: 16),
          // Confidence and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRunning ? 'Detecting...' : 'Ready',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _isRunning
                            ? AppColors.primaryTeal
                            : AppColors.textSecondaryDark,
                      ),
                ),
                const SizedBox(height: 8),
                ConfidenceBar(confidence: _confidence),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.textTertiaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isStable
                          ? 'Gesture confirmed!'
                          : 'Hold steady for 1s...',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isStable
                            ? AppColors.confidenceHigh
                            : AppColors.textTertiaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordPanel(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Word Builder',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          Icons.volume_up_rounded,
                          'Speak',
                          () => provider.speakText(),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.space_bar_rounded,
                          'Space',
                          () => provider.addSpace(),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.backspace_outlined,
                          'Back',
                          () => provider.backspace(),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          Icons.clear_rounded,
                          'Clear',
                          () => provider.clearText(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.glassDarkBorder,
                    ),
                  ),
                  child: Text(
                    provider.wordBuilder.fullText.isEmpty
                        ? 'Detected text will appear here...'
                        : provider.wordBuilder.fullText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: provider.wordBuilder.fullText.isEmpty
                          ? AppColors.textTertiaryDark
                          : AppColors.textPrimaryDark,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (provider.detectedHistory.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: provider.detectedHistory
                        .reversed
                        .take(20)
                        .map((l) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withAlpha(51),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.glassDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassDarkBorder),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondaryDark),
        ),
      ),
    );
  }

  Widget _buildSuggestionsPanel(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final suggestions = provider.wordBuilder.getSuggestions();
        final predictions = provider.wordBuilder.predictNextWords();

        if (suggestions.isEmpty && predictions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (suggestions.isNotEmpty) ...[
                  Text(
                    'Suggestions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: suggestions
                        .map((s) => ActionChip(
                              label: Text(s,
                                  style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                provider.clearText();
                                for (var c in s.split('')) {
                                  provider.confirmLetter(c);
                                }
                              },
                              backgroundColor: AppColors.primaryPurple.withAlpha(51),
                              side: BorderSide(
                                color: AppColors.primaryPurple.withAlpha(77),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                if (predictions.isNotEmpty) ...[
                  if (suggestions.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    'Next Word Predictions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: predictions
                        .map((p) => ActionChip(
                              label: Text(p,
                                  style: const TextStyle(fontSize: 12)),
                              onPressed: () {
                                provider.addSpace();
                                for (var c in p.split('')) {
                                  provider.confirmLetter(c);
                                }
                              },
                              backgroundColor: AppColors.accentOrange.withAlpha(26),
                              side: BorderSide(
                                color: AppColors.accentOrange.withAlpha(77),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryTeal.withAlpha(13)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
