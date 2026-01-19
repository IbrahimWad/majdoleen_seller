import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_navigation.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../core/locale_controller.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/form_section_header.dart';
import '../widgets/labeled_switch_row.dart';
import '../widgets/seller_app_bar.dart';
import '../widgets/seller_bottom_bar.dart';
import '../widgets/seller_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = AppRoutes.settings;

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderUpdates = true;
  bool _payoutUpdates = true;
  bool _marketingUpdates = false;
  bool _lowStockAlerts = true;
  bool _twoFactorAuth = true;
  bool _biometricLogin = false;

  String _selectedLanguage = _languageCodes.first;
  String _selectedCurrency = _currencies.first;
  String _selectedTimeZone = _timeZones.first;

  static const List<String> _languageCodes = [
    'en',
    'ar',
  ];

  static const List<String> _currencies = [
    'SAR',
    'USD',
    'EUR',
  ];

  static const List<String> _timeZones = [
    'Asia/Riyadh',
    'UTC',
    'Europe/London',
  ];

  void _showMessage(String message) {
    showAppSnackBar(context, message);
  }

  String _languageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'ar':
        return l10n.settingsLanguageArabic;
    }
    return code;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final code = _languageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : _languageCodes.first;
    if (_selectedLanguage != code) {
      setState(() {
        _selectedLanguage = code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const SellerAppBar(),
      drawer: const SellerDrawer(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: FormSectionHeader(
                  title: l10n.settingsTitle,
                  subtitle: l10n.settingsSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.settingsNotificationsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    children: [
                      LabeledSwitchRow(
                        title: l10n.settingsOrderUpdatesTitle,
                        subtitle: l10n.settingsOrderUpdatesSubtitle,
                        value: _orderUpdates,
                        onChanged: (value) {
                          setState(() {
                            _orderUpdates = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: l10n.settingsPayoutUpdatesTitle,
                        subtitle: l10n.settingsPayoutUpdatesSubtitle,
                        value: _payoutUpdates,
                        onChanged: (value) {
                          setState(() {
                            _payoutUpdates = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: l10n.settingsLowStockAlertsTitle,
                        subtitle: l10n.settingsLowStockAlertsSubtitle,
                        value: _lowStockAlerts,
                        onChanged: (value) {
                          setState(() {
                            _lowStockAlerts = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: l10n.settingsMarketingUpdatesTitle,
                        subtitle: l10n.settingsMarketingUpdatesSubtitle,
                        value: _marketingUpdates,
                        onChanged: (value) {
                          setState(() {
                            _marketingUpdates = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.settingsSecurityTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    children: [
                      LabeledSwitchRow(
                        title: l10n.settingsTwoFactorTitle,
                        subtitle: l10n.settingsTwoFactorSubtitle,
                        value: _twoFactorAuth,
                        onChanged: (value) {
                          setState(() {
                            _twoFactorAuth = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      LabeledSwitchRow(
                        title: l10n.settingsBiometricTitle,
                        subtitle: l10n.settingsBiometricSubtitle,
                        value: _biometricLogin,
                        onChanged: (value) {
                          setState(() {
                            _biometricLogin = value;
                          });
                        },
                      ),
                      const Divider(height: 24),
                      _SettingsActionTile(
                        icon: Icons.lock_outline,
                        title: l10n.settingsChangePasswordTitle,
                        subtitle: l10n.settingsChangePasswordSubtitle,
                        onTap: () => _showMessage(
                          l10n.settingsPasswordComingSoonMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.settingsPreferencesTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        items: _languageCodes
                            .map(
                              (code) => DropdownMenuItem(
                                value: code,
                                child: Text(_languageLabel(l10n, code)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedLanguage = value;
                          });
                          LocaleScope.of(context).setLocale(Locale(value));
                        },
                        decoration:
                            InputDecoration(labelText: l10n.settingsLanguageLabel),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        items: _currencies
                            .map(
                              (currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedCurrency = value;
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.settingsCurrencyLabel),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTimeZone,
                        items: _timeZones
                            .map(
                              (zone) => DropdownMenuItem(
                                value: zone,
                                child: Text(zone),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedTimeZone = value;
                          });
                        },
                        decoration:
                            InputDecoration(labelText: l10n.settingsTimeZoneLabel),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  l10n.settingsAccountTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    children: [
                      _SettingsActionTile(
                        icon: Icons.workspace_premium_outlined,
                        title: l10n.settingsPlansTitle,
                        subtitle: l10n.settingsPlansSubtitle,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.subscriptionPlans,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsActionTile(
                        icon: Icons.group_outlined,
                        title: l10n.settingsTeamMembersTitle,
                        subtitle: l10n.settingsTeamMembersSubtitle,
                        onTap: () => _showMessage(
                          l10n.settingsTeamComingSoonMessage,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsActionTile(
                        icon: Icons.credit_card_outlined,
                        title: l10n.settingsBillingTitle,
                        subtitle: l10n.settingsBillingSubtitle,
                        onTap: () => _showMessage(
                          l10n.settingsBillingComingSoonMessage,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SettingsActionTile(
                        icon: Icons.help_outline,
                        title: l10n.settingsHelpCenterTitle,
                        subtitle: l10n.settingsHelpCenterSubtitle,
                        onTap: () => _showMessage(
                          l10n.settingsHelpCenterComingSoonMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SellerBottomBar(
        selectedIndex: -1,
        onTap: (index) => handleNavTap(context, index),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kBrandColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: kBrandColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kInkColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
