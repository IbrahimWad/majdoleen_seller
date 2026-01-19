import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_field.dart';
import '../widgets/login_wave_clipper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = AppRoutes.forgotPassword;

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAppSnackBar(context, l10n.forgotPasswordEmailRequired);
      return;
    }
    setState(() {
      _sent = true;
    });
    showAppSnackBar(context, l10n.forgotPasswordSentMessage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final surface = Color.lerp(kSurfaceColor, Colors.white, 0.4)!;
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: surface,
        systemNavigationBarDividerColor: surface,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: surface,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: ClipPath(
                    clipper: LoginWaveClipper(),
                    child: Container(
                      color: kBrandColor,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: topInset + 24),
                          child: Image.asset(
                            'assets/branding/majdoleen_splash.png',
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment:
                            isRtl ? Alignment.centerRight : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: isRtl
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.forgotPasswordTitle,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: kInkColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: kBrandColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.forgotPasswordSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: kInkColor.withOpacity(0.7),
                          fontSize:
                              (theme.textTheme.bodyMedium?.fontSize ?? 14) *
                                  1.05,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_sent)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kSuccessColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mark_email_read_outlined,
                                color: kSuccessColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.forgotPasswordSentMessage,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: kInkColor.withOpacity(0.75),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      LoginField(
                        controller: _emailController,
                        label: l10n.emailLabel,
                        hint: l10n.emailHint,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _sendResetLink(),
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBrandColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: kBrandColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.forgotPasswordHelper,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: kInkColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kBrandColor, kBrandDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: kBrandColor.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _sendResetLink,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    l10n.forgotPasswordAction,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.forgotPasswordRememberPrompt,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kInkColor.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandColor,
                            ),
                            child: Text(l10n.forgotPasswordBackToLogin),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
