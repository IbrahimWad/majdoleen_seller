import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_shadows.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Locale deviceLocale;
  final Future<void> Function(Locale) onSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.deviceLocale,
    required this.onSelected,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.deviceLocale.languageCode == 'ar'
        ? const Locale('ar')
        : const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabicDevice = widget.deviceLocale.languageCode == 'ar';
    final detectedLabel = isArabicDevice ? 'العربية' : 'English';
    final detectedLocale =
        isArabicDevice ? const Locale('ar') : const Locale('en');
    final hintColor = kInkColor.withOpacity(0.6);
    final continueLabel = isArabicDevice ? 'متابعة' : 'Continue';

    Future<void> handleContinue() async {
      final locale = _selectedLocale ?? detectedLocale;
      await widget.onSelected(locale);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    }

    void selectLocale(Locale locale) {
      setState(() {
        _selectedLocale = locale;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kSurfaceColor, Color(0xFFFDFBFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBrandColor.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBrandColor.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: kSoftShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/branding/majdoleen_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Majdoleen Seller',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Start in your preferred language',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Choose your language',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر اللغة المفضلة لك',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: kSoftShadow,
                    border: Border.all(color: kBrandColor.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kBrandColor, kBrandDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detected on your device',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detectedLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kBrandColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isArabicDevice ? 'مقترحة' : 'Recommended',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: kBrandColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Or select manually',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أو اختر يدوياً',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 14),
                _LanguageOptionCard(
                  title: 'العربية',
                  subtitle: 'Arabic',
                  codeLabel: 'AR',
                  isRecommended: isArabicDevice,
                  isSelected: _selectedLocale?.languageCode == 'ar',
                  onTap: () => selectLocale(const Locale('ar')),
                ),
                const SizedBox(height: 12),
                _LanguageOptionCard(
                  title: 'English',
                  subtitle: 'English',
                  codeLabel: 'EN',
                  isRecommended: !isArabicDevice,
                  isSelected: _selectedLocale?.languageCode == 'en',
                  onTap: () => selectLocale(const Locale('en')),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: handleContinue,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(continueLabel),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your choice will be saved on this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سيتم حفظ اختيارك على هذا الجهاز.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String codeLabel;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.codeLabel,
    required this.isRecommended,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintColor = kInkColor.withOpacity(0.6);
    final backgroundColor = isSelected
        ? kBrandColor.withOpacity(0.12)
        : (isRecommended ? kBrandColor.withOpacity(0.06) : Colors.white);
    final borderColor = isSelected
        ? kBrandColor
        : (isRecommended
            ? kBrandColor.withOpacity(0.35)
            : kBrandColor.withOpacity(0.12));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: kSoftShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kBrandColor, kBrandDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    codeLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hintColor,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: kBrandColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Recommended',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: kBrandColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? kBrandColor : hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
