import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  List<_OnboardingStep> _buildSteps(AppLocalizations l10n) {
    return [
      _OnboardingStep(
        title: l10n.welcomeStep1Title,
        subtitle: l10n.welcomeStep1Subtitle,
        imagePath: 'assets/branding/majdoleen_logo.png',
        accentColor: const Color(0xFFF1E4F4),
        highlights: [
          l10n.welcomeStep1Highlight1,
          l10n.welcomeStep1Highlight2,
          l10n.welcomeStep1Highlight3,
        ],
      ),
      _OnboardingStep(
        title: l10n.welcomeStep2Title,
        subtitle: l10n.welcomeStep2Subtitle,
        imagePath: 'assets/branding/majdoleen_logo.png',
        accentColor: const Color(0xFFEBD8F1),
        highlights: [
          l10n.welcomeStep2Highlight1,
          l10n.welcomeStep2Highlight2,
          l10n.welcomeStep2Highlight3,
        ],
      ),
      _OnboardingStep(
        title: l10n.welcomeStep3Title,
        subtitle: l10n.welcomeStep3Subtitle,
        imagePath: 'assets/branding/majdoleen_logo.png',
        accentColor: const Color(0xFFF6EAF8),
        highlights: [
          l10n.welcomeStep3Highlight1,
          l10n.welcomeStep3Highlight2,
          l10n.welcomeStep3Highlight3,
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    final steps = _buildSteps(AppLocalizations.of(context));
    if (_currentIndex == steps.length - 1) {
      _goToLogin();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final steps = _buildSteps(l10n);
    final accent = steps[_currentIndex].accentColor;
    final nextLabel = _currentIndex == steps.length - 1
        ? l10n.welcomeGetStarted
        : l10n.welcomeNext;

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kSurfaceColor, Color(0xFFFDFBFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 140,
                      left: -60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: kBrandColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          l10n.welcomeAppName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: accent.withOpacity(0.45),
                            ),
                          ),
                          child: Text(
                            l10n.welcomeSellerAppBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: kBrandColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: steps.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingCard(
                          step: steps[index],
                          index: index,
                          total: steps.length,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: kSoftShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentIndex + 1}/${steps.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: kInkColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  steps.length,
                                  (index) {
                                    final isActive = index == _currentIndex;
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 3),
                                      height: 8,
                                      width: isActive ? 22 : 8,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? kBrandColor
                                            : kBrandColor.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _goToLogin,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: kBrandColor.withOpacity(0.35),
                            ),
                          ),
                          child: Text(l10n.welcomeSkip),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              nextLabel,
                              key: ValueKey(nextLabel),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color accentColor;
  final List<String> highlights;

  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.accentColor,
    required this.highlights,
  });
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingStep step;
  final int index;
  final int total;

  const _OnboardingCard({
    required this.step,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        step.accentColor,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: step.accentColor.withOpacity(0.4),
                    ),
                    boxShadow: kSoftShadow,
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: step.accentColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kBrandColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.welcomeStepIndicator(index + 1, total),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_graph_outlined,
                          size: 14,
                          color: kBrandColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.welcomeSellerKit,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kBrandColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.92, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: kSoftShadow,
                        border: Border.all(
                          color: step.accentColor.withOpacity(0.25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Image.asset(
                          step.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: kInkColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: step.highlights
                .map((label) => _OnboardingHighlight(label: label))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OnboardingHighlight extends StatelessWidget {
  final String label;

  const _OnboardingHighlight({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: kBrandColor.withOpacity(0.15),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: kInkColor.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
