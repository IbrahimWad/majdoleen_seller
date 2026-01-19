import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../services/phone_verification_service.dart';
import '../services/seller_auth_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_wave_clipper.dart';

class VerificationScreen extends StatefulWidget {
  static const String routeName = AppRoutes.verification;

  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final PhoneVerificationService _phoneVerificationService = PhoneVerificationService();
  final SellerAuthService _sellerAuthService = SellerAuthService();

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  bool _isResending = false;
  bool _hasStartedResendTimer = false;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;

  static const int _resendIntervalSeconds = 60;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user data passed from register screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userData = args;
    }
    if (_userData != null && !_hasStartedResendTimer) {
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
    if (_userData == null) return;
    if (_isResending || _resendSecondsLeft > 0) return;

    setState(() => _isResending = true);

    try {
      await _phoneVerificationService.sendOTP(_userData!['phone']);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(context, l10n.verificationResentMessage);
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final message = _localizeVerificationError(e, l10n);
        showAppSnackBar(
          context,
          message == l10n.verificationUnexpectedError
              ? l10n.verificationResendFailed
              : message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String _resendButtonLabel(AppLocalizations l10n) {
    if (_resendSecondsLeft > 0) {
      return l10n.verificationResendIn.replaceFirst(
        '{seconds}',
        _resendSecondsLeft.toString(),
      );
    }
    return l10n.verificationResendAction;
  }

  Future<void> _verify() async {
    if (_userData == null) return;

    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showAppSnackBar(context, l10n.verificationCodeRequired);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // Verify OTP with Firebase
      final firebaseToken = await _phoneVerificationService.verifyOTP(code);

      if (firebaseToken == null) {
        if (mounted) {
          showAppSnackBar(context, l10n.verificationUnexpectedError);
        }
        return;
      }

      final firebaseLogin = await _sellerAuthService.verifyFirebaseToken(
        idToken: firebaseToken,
        name: _userData?['fullName'],
      );

      final authToken =
          firebaseLogin['token'] is String ? firebaseLogin['token'] as String : null;

      await _sellerAuthService.registerSeller(
        email: _userData!['email'],
        name: _userData!['fullName'],
        password: _userData!['password'],
        passwordConfirmation:
            _userData!['passwordConfirmation'] ?? _userData!['password'],
        phone: _userData!['phone'],
        shopName: _userData!['shopName'],
        shopPhone: _userData!['shopPhone'],
        address: _userData!['address'],
        authToken: authToken,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.approvalPending);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, _localizeVerificationError(e, l10n));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _localizeVerificationError(Object error, AppLocalizations l10n) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-verification-code':
          return l10n.verificationInvalidCode;
        case 'invalid-verification-id':
        case 'code-expired':
        case 'session-expired':
          return l10n.verificationCodeExpired;
        case 'too-many-requests':
        case 'quota-exceeded':
          return l10n.verificationTooManyRequests;
        case 'invalid-phone-number':
          return l10n.verificationInvalidPhone;
        case 'network-request-failed':
          return l10n.verificationNetworkError;
        case 'operation-not-allowed':
        case 'app-not-authorized':
          return l10n.verificationProviderDisabled;
        default:
          break;
      }
    }

    final message = error.toString().toLowerCase();

    if (message.contains('invalid verification code') ||
        message.contains('verification code is invalid') ||
        message.contains('invalid code')) {
      return l10n.verificationInvalidCode;
    }
    if (message.contains('code has expired') ||
        message.contains('sms code has expired') ||
        message.contains('verification code has expired') ||
        message.contains('session expired')) {
      return l10n.verificationCodeExpired;
    }
    if (message.contains('too many requests') ||
        message.contains('quota exceeded') ||
        message.contains('blocked all requests')) {
      return l10n.verificationTooManyRequests;
    }
    if (message.contains('invalid phone') ||
        (message.contains('phone number') &&
            (message.contains('incorrect') ||
                message.contains('not valid') ||
                message.contains('e.164')))) {
      return l10n.verificationInvalidPhone;
    }
    if (message.contains('sms unable to be sent') ||
        (message.contains('region') && message.contains('enabled'))) {
      return l10n.verificationSmsRegionBlocked;
    }
    if (message.contains('sign-in provider is disabled') ||
        message.contains('operation is not allowed')) {
      return l10n.verificationProviderDisabled;
    }
    if (message.contains('network') ||
        message.contains('socketexception') ||
        message.contains('failed to connect')) {
      return l10n.verificationNetworkError;
    }
    if (message.contains('invalid firebase token')) {
      return l10n.verificationBackendInvalidToken;
    }
    if (message.contains('phone number missing')) {
      return l10n.verificationBackendMissingPhone;
    }
    if (message.contains('firebase credentials misconfigured')) {
      return l10n.verificationBackendMisconfigured;
    }

    return l10n.verificationUnexpectedError;
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
        body: Stack(
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
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 200),
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
                              l10n.verificationTitle,
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
                      'Enter the 6-digit code sent to ${_userData?['phone'] ?? 'your phone'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: kInkColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: kSoftShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: kBrandColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.phone_android,
                                  color: kBrandColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'We sent a verification code to ${_userData?['phone'] ?? 'your phone number'}',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: kInkColor.withOpacity(0.75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.verificationCodeLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [
                              AutofillHints.oneTimeCode,
                            ],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 12,
                            ),
                            onSubmitted: (_) => _verify(),
                            decoration: InputDecoration(
                              hintText: '000000',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: kInkColor.withOpacity(0.4),
                              ),
                              filled: true,
                              fillColor: kSurfaceColor.withOpacity(0.6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: kBrandColor,
                                  width: 1.5,
                                ),
                              ),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.verificationResendPrompt,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: kInkColor.withOpacity(0.6),
                                ),
                              ),
                              TextButton(
                                onPressed: (_isResending || _resendSecondsLeft > 0)
                                    ? null
                                    : _resendCode,
                                child: _isResending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(_resendButtonLabel(l10n)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        l10n.verificationVerifyAction,
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
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back to Registration'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
