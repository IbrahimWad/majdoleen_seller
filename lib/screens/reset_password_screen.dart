import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../services/seller_auth_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_field.dart';
import '../widgets/login_wave_clipper.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = AppRoutes.resetPassword;

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final SellerAuthService _authService = SellerAuthService();

  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _resetToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _resetToken = args['reset_token'] as String?;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePasswords() {
    final l10n = AppLocalizations.of(context);
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      showAppSnackBar(context, l10n.resetPasswordRequired);
      return false;
    }

    if (password.length < 6) {
      showAppSnackBar(context, l10n.resetPasswordMinLength);
      return false;
    }

    if (confirmPassword.isEmpty) {
      showAppSnackBar(context, l10n.resetPasswordConfirmRequired);
      return false;
    }

    if (password != confirmPassword) {
      showAppSnackBar(context, l10n.resetPasswordMismatch);
      return false;
    }

    return true;
  }

  Future<void> _resetPassword() async {
    if (!_validatePasswords()) return;
    if (_resetToken == null || _resetToken!.isEmpty) {
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(context, l10n.resetPasswordTokenError);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _authService.resetPassword(
        resetToken: _resetToken!,
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        if (result['success'] == true) {
          showAppSnackBar(context, l10n.resetPasswordSuccess);
          // Navigate to login after 1.5 seconds
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
        } else {
          final error = result['error'] ?? result['message'] ?? l10n.resetPasswordFailed;
          showAppSnackBar(context, error.toString());
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String message = l10n.resetPasswordFailed;

        if (e.toString().contains('Invalid reset token')) {
          message = l10n.resetPasswordInvalidToken;
        } else if (e.toString().contains('expired')) {
          message = l10n.resetPasswordExpiredToken;
        } else if (e is Exception) {
          final errorMsg = e.toString().replaceAll('Exception: ', '');
          message = errorMsg.isEmpty ? message : errorMsg;
        }

        showAppSnackBar(context, message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: isRtl
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.resetPasswordTitle,
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
                        l10n.resetPasswordSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: kInkColor.withOpacity(0.7),
                          fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 1.05,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LoginField(
                        controller: _passwordController,
                        label: l10n.resetPasswordLabel,
                        hint: l10n.resetPasswordHint,
                        icon: Icons.lock_outline,
                        obscure: !_showPassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                          child: Icon(
                            _showPassword ? Icons.visibility_off : Icons.visibility,
                            color: kBrandColor,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: 16),
                      LoginField(
                        controller: _confirmPasswordController,
                        label: l10n.resetPasswordConfirmLabel,
                        hint: l10n.resetPasswordConfirmHint,
                        icon: Icons.lock_outline,
                        obscure: !_showConfirmPassword,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() => _showConfirmPassword = !_showConfirmPassword);
                          },
                          child: Icon(
                            _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: kBrandColor,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _resetPassword(),
                        autofillHints: const [AutofillHints.password],
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
                                l10n.resetPasswordHelper,
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
                              onTap: _isLoading ? null : _resetPassword,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          l10n.resetPasswordAction,
                                          style:
                                              theme.textTheme.titleLarge?.copyWith(
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
                            l10n.resetPasswordBackPrompt,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kInkColor.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandColor,
                            ),
                            child: Text(l10n.resetPasswordBackToLogin),
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
