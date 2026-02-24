import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../widgets/animated_hand_icon.dart';
import '../widgets/feature_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildQuickActions(context),
            _buildFeaturesGrid(context),
            _buildInfoSection(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0E3E),
            Color(0xFF0A0E21),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background glow
          Positioned(
            right: -50,
            top: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.purpleGlow,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.tealGlow,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.saffron.withAlpha(51),
                                AppColors.indiaGreen.withAlpha(51),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.saffron.withAlpha(77),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇮🇳', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text(
                                'Made for India',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.saffron,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppGradients.primary.createShader(bounds),
                          child: Text(
                            'ISL\nTranslator',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  height: 1.1,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Real-time Indian Sign Language\ntranslation powered by AI',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondaryDark,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const AnimatedHandIcon(size: 120),
                ],
              ),
              const SizedBox(height: 8),
              // Stats row
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Consumer<AppProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          context,
                          '${provider.analyticsService.accuracyPercentage.toStringAsFixed(0)}%',
                          'Accuracy',
                          AppColors.confidenceHigh,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.glassDarkBorder,
                        ),
                        _buildStat(
                          context,
                          '${provider.analyticsService.totalLetters}',
                          'Letters',
                          AppColors.primaryTeal,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.glassDarkBorder,
                        ),
                        _buildStat(
                          context,
                          '${provider.analyticsService.totalSessions}',
                          'Sessions',
                          AppColors.accentOrange,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'Start Translating',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => provider.setCurrentIndex(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: 'Learn ISL',
                  icon: Icons.school_rounded,
                  gradient: AppGradients.accent,
                  onPressed: () => provider.setCurrentIndex(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              FeatureCard(
                icon: Icons.sign_language,
                title: 'Real-time',
                subtitle: 'Live gesture recognition',
                iconGradient: AppGradients.primary,
                onTap: () => provider.setCurrentIndex(1),
              ),
              FeatureCard(
                icon: Icons.text_fields_rounded,
                title: 'Word Builder',
                subtitle: 'Smart word formation',
                iconGradient: AppGradients.accent,
                onTap: () => provider.setCurrentIndex(1),
              ),
              FeatureCard(
                icon: Icons.volume_up_rounded,
                title: 'Text to Speech',
                subtitle: 'Bi-directional output',
                iconGradient: const LinearGradient(
                  colors: [AppColors.confidenceHigh, AppColors.primaryTeal],
                ),
                onTap: () => provider.setCurrentIndex(1),
              ),
              FeatureCard(
                icon: Icons.school_rounded,
                title: 'Learn & Practice',
                subtitle: 'Interactive ISL lessons',
                iconGradient: const LinearGradient(
                  colors: [AppColors.saffron, AppColors.accentAmber],
                ),
                onTap: () => provider.setCurrentIndex(2),
              ),
              FeatureCard(
                icon: Icons.analytics_rounded,
                title: 'Analytics',
                subtitle: 'Track your progress',
                iconGradient: const LinearGradient(
                  colors: [AppColors.info, AppColors.primaryPurple],
                ),
                onTap: () => provider.setCurrentIndex(3),
              ),
              FeatureCard(
                icon: Icons.wifi_off_rounded,
                title: 'Offline Mode',
                subtitle: 'Works without internet',
                iconGradient: const LinearGradient(
                  colors: [AppColors.indiaGreen, AppColors.primaryTeal],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.primary.createShader(bounds),
                  child: const Icon(Icons.lightbulb_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'About ISL Translator',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A lightweight, India-specific, real-time Indian Sign Language translation solution with intelligent word formation, gesture stability detection, offline capability, and bi-directional communication support.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(context, '🤖 AI Powered'),
                _buildTag(context, '🇮🇳 India-Specific'),
                _buildTag(context, '⚡ Real-time'),
                _buildTag(context, '📴 Offline Ready'),
                _buildTag(context, '♿ Accessible'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withAlpha(51),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
