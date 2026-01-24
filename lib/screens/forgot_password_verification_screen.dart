import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../services/seller_auth_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_wave_clipper.dart';

class ForgotPasswordVerificationScreen extends StatefulWidget {
  static const String routeName = AppRoutes.forgotPasswordVerification;

  const ForgotPasswordVerificationScreen({super.key});

  @override
  State<ForgotPasswordVerificationScreen> createState() =>
      _ForgotPasswordVerificationScreenState();
}

class _ForgotPasswordVerificationScreenState
    extends State<ForgotPasswordVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final SellerAuthService _authService = SellerAuthService();

  String? _phone;
  bool _isLoading = false;
  bool _isResending = false;
  bool _hasStartedResendTimer = false;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;

  static const int _resendIntervalSeconds = 60;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _phone = args['phone'] as String?;
    }
    if (_phone != null && !_hasStartedResendTimer) {
      _hasStartedResendTimer = true;
      _startResendCountdown();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendIntervalSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_phone == null) return;
    if (_isResending || _resendSecondsLeft > 0) return;

    setState(() => _isResending = true);

    try {
      await _authService.sendForgotPasswordOtp(phone: _phone!);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(context, l10n.forgotPasswordOtpResent);
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final message = _localizeForgotPasswordError(e, l10n);
        showAppSnackBar(context, message);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String _resendButtonLabel(AppLocalizations l10n) {
    if (_resendSecondsLeft > 0) {
      return l10n.forgotPasswordResendIn(_resendSecondsLeft.toString());
    }
    return l10n.forgotPasswordResendAction;
  }

  String _localizeForgotPasswordError(dynamic error, AppLocalizations l10n) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('expired')) {
        return l10n.forgotPasswordOtpExpired;
      }
      if (msg.contains('invalid') || msg.contains('Invalid')) {
        return l10n.forgotPasswordOtpInvalid;
      }
    }
    return l10n.forgotPasswordOtpVerificationFailed;
  }

  Future<void> _verify() async {
    if (_phone == null) return;

    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showAppSnackBar(context, l10n.forgotPasswordOtpRequired);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _authService.verifyForgotPasswordOtp(
        phone: _phone!,
        otp: code,
      );

      if (mounted) {
        if (result['success'] == true) {
          final resetToken = result['reset_token'] as String? ?? '';
          showAppSnackBar(context, l10n.forgotPasswordOtpVerified);
          
          // Navigate to reset password screen
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pushNamed(
              AppRoutes.resetPassword,
              arguments: {
                'reset_token': resetToken,
              },
            );
          }
        } else {
          final error = result['error'] ?? result['message'] ?? l10n.forgotPasswordOtpVerificationFailed;
          showAppSnackBar(context, error.toString());
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final message = _localizeForgotPasswordError(e, l10n);
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
                                l10n.forgotPasswordVerifyTitle,
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
                        l10n.forgotPasswordVerifySubtitle(_phone ?? ''),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: kInkColor.withOpacity(0.7),
                          fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 1.05,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _codeController,
                        enabled: !_isLoading,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: theme.textTheme.headlineMedium?.copyWith(
                            color: kInkColor.withOpacity(0.3),
                            letterSpacing: 8,
                          ),
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: kBrandColor.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: kBrandColor.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: kBrandColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                        ),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          letterSpacing: 8,
                          color: kInkColor,
                          fontWeight: FontWeight.w600,
                        ),
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
                                l10n.forgotPasswordVerifyHelper,
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
                              onTap: _isLoading ? null : _verify,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          l10n.forgotPasswordVerifyAction,
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
                            l10n.forgotPasswordVerifyNoCodePrompt,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kInkColor.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _isResending || _resendSecondsLeft > 0
                                ? null
                                : _resendCode,
                            style: TextButton.styleFrom(
                              foregroundColor: kBrandColor,
                            ),
                            child: Text(_resendButtonLabel(l10n)),
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
