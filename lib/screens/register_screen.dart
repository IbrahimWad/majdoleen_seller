import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_shadows.dart';
import '../services/seller_auth_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_field.dart';
import '../widgets/login_wave_clipper.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = AppRoutes.register;

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _totalSteps = 3;
  static final Uri _termsUri = Uri.parse('https://example.com/terms');
  static const String _citiesCountryId = '104';

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopUrlController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _sellerAuthService = SellerAuthService();

  Country? _selectedCountry;
  String? _phoneE164;
  String? _verificationToken;
  String? _selectedGender;
  String? _selectedCity;
  List<String> _cities = [];
  bool _isLoadingCities = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('IQ');
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCities());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopPhoneController.dispose();
    _shopUrlController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoadingCities = true);

    try {
      final cities =
          await _sellerAuthService.fetchStatesOfCountry(countryId: _citiesCountryId);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        if (_selectedCity != null && !_cities.contains(_selectedCity)) {
          _selectedCity = null;
        }
      });
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Load cities failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(context, l10n.registerCityLoadFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() => _selectedCountry = country);
      },
    );
  }

  bool _isValidE164(String value) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(value);
  }

  String? _formatPhoneE164() {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty) return null;

    if (raw.startsWith('+')) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      final e164 = '+$digits';
      return _isValidE164(e164) ? e164 : null;
    }

    final country = _selectedCountry;
    if (country == null) return null;

    var digits = raw.replaceAll(RegExp(r'\D'), '');
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) return null;

    final e164 = '+${country.phoneCode}$digits';
    return _isValidE164(e164) ? e164 : null;
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = 60);
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
    final l10n = AppLocalizations.of(context);
    if (_phoneE164 == null) {
      showAppSnackBar(context, l10n.verificationInvalidPhone);
      return;
    }
    if (_isResending || _resendSecondsLeft > 0) return;

    setState(() => _isResending = true);

    try {
      await _sellerAuthService.sendOtp(
        phone: _phoneE164!,
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );
      if (mounted) {
        showAppSnackBar(context, l10n.verificationResentMessage);
        _startResendCountdown();
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Send OTP resend failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(context, l10n.verificationResendFailed);
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

  Future<void> _submitStepOne() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null &&
        !_phoneController.text.trim().startsWith('+')) {
      showAppSnackBar(context, l10n.registerCountryCodeRequired);
      return;
    }

    if (!_acceptedTerms) {
      showAppSnackBar(context, l10n.registerTermsRequired);
      return;
    }

    final phoneE164 = _formatPhoneE164();
    if (phoneE164 == null) {
      showAppSnackBar(context, l10n.verificationInvalidPhone);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await _sellerAuthService.sendOtp(
        phone: phoneE164,
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
      );
      if (mounted) {
        _codeController.clear();
        _startResendCountdown();
        setState(() {
          _phoneE164 = phoneE164;
          _verificationToken = null;
          _currentStep = 1;
        });
        showAppSnackBar(context, l10n.verificationSentToPhone);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        debugPrint('Send OTP failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        showAppSnackBar(context, l10n.registerSendOtpFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showAppSnackBar(context, l10n.verificationCodeRequired);
      return;
    }

    final phone = _phoneE164;
    if (phone == null) {
      showAppSnackBar(context, l10n.verificationInvalidPhone);
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await _sellerAuthService.verifyOtp(
        phone: phone,
        otp: code,
      );
      final token = response['verification_token'];
      if (token is! String || token.isEmpty) {
        if (mounted) {
          showAppSnackBar(context, l10n.verificationUnexpectedError);
        }
        return;
      }
      if (mounted) {
        _resendTimer?.cancel();
        setState(() {
          _verificationToken = token;
          _currentStep = 2;
        });
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

  Future<void> _completeRegistration() async {
    final l10n = AppLocalizations.of(context);
    final phone = _phoneE164;
    final token = _verificationToken;

    if (phone == null) {
      showAppSnackBar(context, l10n.verificationInvalidPhone);
      setState(() => _currentStep = 0);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      showAppSnackBar(context, l10n.registerGenderRequired);
      return;
    }

    if (_selectedCity == null || _selectedCity!.isEmpty) {
      showAppSnackBar(context, l10n.registerCityRequired);
      return;
    }

    if (token == null || token.isEmpty) {
      showAppSnackBar(context, l10n.registerVerificationTokenMissing);
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      await _sellerAuthService.completeRegistration(
        verificationToken: token,
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        gender: _selectedGender!,
        city: _selectedCity!,
        birthdate: _birthdateController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopPhone: _shopPhoneController.text.trim(),
        shopUrl: _shopUrlController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.approvalPending);
      }
    } catch (e, stackTrace) {
      debugPrint('Complete registration failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, l10n.registerCompleteFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openTerms() async {
    final launched = await launchUrl(
      _termsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      showAppSnackBar(context, AppLocalizations.of(context).registerTermsOpenFailed);
    }
  }

  String _formatBirthdate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _pickBirthdate(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parsed = DateTime.tryParse(_birthdateController.text.trim());
    var initialDate = parsed ?? DateTime(today.year - 18, today.month, today.day);
    if (initialDate.isAfter(today)) {
      initialDate = today;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: l10n.registerBirthdatePickerTitle,
      locale: Localizations.localeOf(context),
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = _formatBirthdate(picked);
      });
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

    if (message.contains('invalid otp') ||
        message.contains('verification code is invalid') ||
        message.contains('invalid verification code') ||
        message.contains('invalid code')) {
      return l10n.verificationInvalidCode;
    }
    if (message.contains('otp expired') ||
        message.contains('code has expired') ||
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

  Widget _buildStepIndicator(ThemeData theme, AppLocalizations l10n) {
    final label = l10n.welcomeStepIndicator(_currentStep + 1, _totalSteps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kInkColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_totalSteps, (index) {
            final isActive = index <= _currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsetsDirectional.only(
                  end: index == _totalSteps - 1 ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? kBrandColor : kBrandColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    ThemeData theme,
    String label,
    VoidCallback? onTap, {
    double textScale = 1,
  }) {
    final baseStyle = theme.textTheme.titleLarge;
    final fontSize = (baseStyle?.fontSize ?? 20) * textScale;

    return SizedBox(
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
            onTap: _isLoading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        label,
                        style: baseStyle?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: fontSize,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _registerHintStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.bodyMedium;
    final fontSize = (baseStyle?.fontSize ?? 14) * 0.9;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      color: kInkColor.withOpacity(0.45),
    );
  }

  Widget _buildPhoneWithCountryCode(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final baseLabelSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final labelSize = baseLabelSize * 1.15;
    final fieldVerticalPadding = 16.0 * 1.15;
    final codeLabel = _selectedCountry == null
        ? l10n.registerCountryCodeShort
        : '+${_selectedCountry!.phoneCode}';
    final flagEmoji = _selectedCountry?.flagEmoji;
    final hintStyle = _registerHintStyle(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.phoneLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kInkColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          decoration: InputDecoration(
            hintText: l10n.phoneHint,
            hintStyle: hintStyle,
            prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 0, end: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _selectCountry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kBrandColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (flagEmoji != null) ...[
                          Text(
                            flagEmoji,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: labelSize,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ] else ...[
                          const Icon(
                            Icons.public,
                            size: 16,
                            color: kBrandColor,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          codeLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: kBrandColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more,
                          size: 18,
                          color: kBrandColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: fieldVerticalPadding),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kInkColor.withOpacity(0.2),
                width: 1.2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBrandColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStepOne(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return [
      _buildPhoneWithCountryCode(theme, l10n),
      const SizedBox(height: 16),
      LoginField(
        controller: _passwordController,
        label: l10n.passwordLabel,
        hint: l10n.passwordHint,
        icon: Icons.lock_outline,
        obscure: _obscurePassword,
        autofillHints: const [AutofillHints.newPassword],
        hintStyle: _registerHintStyle(theme),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: kBrandColor,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.registerPasswordRequired;
          }
          if (value.trim().length < 6) {
            return l10n.registerPasswordMinLength;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      LoginField(
        controller: _confirmPasswordController,
        label: l10n.confirmPasswordLabel,
        hint: l10n.confirmPasswordLabel,
        icon: Icons.lock_outline,
        obscure: _obscureConfirmPassword,
        autofillHints: const [AutofillHints.newPassword],
        hintStyle: _registerHintStyle(theme),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kBrandColor,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.registerConfirmPasswordRequired;
          }
          if (value.trim() != _passwordController.text.trim()) {
            return l10n.registerPasswordMismatch;
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: kInkColor.withOpacity(0.2),
              ),
              activeColor: kBrandColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.registerTermsPrefix,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kInkColor.withOpacity(0.75),
                  ),
                ),
                TextButton(
                  onPressed: _openTerms,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: kBrandColor,
                  ),
                  child: Text(
                    l10n.registerTermsLink,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kBrandColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  l10n.registerTermsSuffix,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: kInkColor.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _buildPrimaryButton(
        theme,
        l10n.registerSendOtpAction,
        _submitStepOne,
        textScale: 0.9,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.alreadyHaveAccountPrompt,
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
            child: Text(l10n.loginLink),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStepTwo(ThemeData theme, AppLocalizations l10n) {
    return [
      Text(
        l10n.registerOtpInstruction(_phoneE164 ?? l10n.phoneLabel),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: kInkColor.withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 16),
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
                    l10n.registerOtpSentTo(_phoneE164 ?? l10n.phoneLabel),
                    style: theme.textTheme.bodyMedium?.copyWith(
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
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
              ),
              onSubmitted: (_) => _verifyCode(),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: kInkColor.withOpacity(0.4),
                  fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 0.9,
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
                  onPressed:
                      (_isResending || _resendSecondsLeft > 0) ? null : _resendCode,
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
      const SizedBox(height: 16),
      _buildPrimaryButton(theme, l10n.verificationVerifyAction, _verifyCode),
      const SizedBox(height: 10),
      Center(
        child: TextButton(
          onPressed: _isLoading ? null : () => setState(() => _currentStep = 0),
          child: Text(l10n.registerBackAction),
        ),
      ),
    ];
  }

  Widget _buildGenderField(ThemeData theme, AppLocalizations l10n) {
    final baseLabelSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final labelSize = baseLabelSize * 1.15;
    final fieldVerticalPadding = 16.0 * 1.15;
    final hintStyle = _registerHintStyle(theme);
    final genderOptions = <String, String>{
      'male': l10n.registerGenderMale,
      'female': l10n.registerGenderFemale,
      'other': l10n.registerGenderOther,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registerGenderLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kInkColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          items: genderOptions.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedGender = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.registerGenderRequired;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: l10n.registerGenderHint,
            hintStyle: hintStyle,
            prefixIcon: const Icon(
              Icons.person_outline,
              size: 22,
              color: kBrandColor,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: fieldVerticalPadding),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kInkColor.withOpacity(0.2),
                width: 1.2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBrandColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityField(ThemeData theme, AppLocalizations l10n) {
    final baseLabelSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final labelSize = baseLabelSize * 1.15;
    final fieldVerticalPadding = 16.0 * 1.15;
    final hintStyle = _registerHintStyle(theme);
    final isEmpty = _cities.isEmpty && !_isLoadingCities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.registerCityLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: kInkColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedCity,
          items: _cities
              .map(
                (city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ),
              )
              .toList(),
          onChanged: _isLoadingCities ? null : (value) => setState(() {
            _selectedCity = value;
          }),
          validator: (value) {
            if (_isLoadingCities) {
              return l10n.registerCityLoading;
            }
            if (isEmpty) {
              return l10n.registerCityEmpty;
            }
            if (value == null || value.isEmpty) {
              return l10n.registerCityRequired;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: _isLoadingCities
                ? l10n.registerCityLoading
                : (isEmpty ? l10n.registerCityEmpty : l10n.registerCityHint),
            hintStyle: hintStyle,
            prefixIcon: const Icon(
              Icons.location_city_outlined,
              size: 22,
              color: kBrandColor,
            ),
            suffixIcon: _isLoadingCities
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: fieldVerticalPadding),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: kInkColor.withOpacity(0.2),
                width: 1.2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBrandColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStepThree(ThemeData theme, AppLocalizations l10n) {
    return [
      LoginField(
        controller: _fullNameController,
        label: l10n.fullNameLabel,
        hint: l10n.fullNameLabel,
        icon: Icons.person_outline,
        keyboardType: TextInputType.name,
        autofillHints: const [AutofillHints.name],
        hintStyle: _registerHintStyle(theme),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.registerNameRequired;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      LoginField(
        controller: _emailController,
        label: l10n.emailLabel,
        hint: l10n.emailHint,
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        hintStyle: _registerHintStyle(theme),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return null;
          }
          final email = value.trim();
          final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
          return isValid ? null : l10n.registerEmailInvalid;
        },
      ),
      const SizedBox(height: 16),
      LoginField(
        controller: _shopNameController,
        label: l10n.registerShopNameLabel,
        hint: l10n.registerShopNameHint,
        icon: Icons.storefront_outlined,
        keyboardType: TextInputType.name,
        hintStyle: _registerHintStyle(theme),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.registerShopNameRequired;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      LoginField(
        controller: _shopPhoneController,
        label: l10n.registerShopPhoneLabel,
        hint: l10n.registerShopPhoneHint,
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        hintStyle: _registerHintStyle(theme),
      ),
      const SizedBox(height: 16),
      LoginField(
        controller: _shopUrlController,
        label: l10n.registerShopUrlLabel,
        hint: l10n.registerShopUrlHint,
        icon: Icons.link_outlined,
        keyboardType: TextInputType.url,
        hintStyle: _registerHintStyle(theme),
      ),
      const SizedBox(height: 16),
      _buildGenderField(theme, l10n),
      const SizedBox(height: 16),
      _buildCityField(theme, l10n),
      const SizedBox(height: 16),
      LoginField(
        controller: _birthdateController,
        label: l10n.registerBirthdateLabel,
        hint: l10n.registerBirthdateHint,
        icon: Icons.cake_outlined,
        keyboardType: TextInputType.datetime,
        hintStyle: _registerHintStyle(theme),
        readOnly: true,
        onTap: () => _pickBirthdate(l10n),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: kBrandColor,
          ),
          onPressed: () => _pickBirthdate(l10n),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.registerBirthdateRequired;
          }
          final text = value.trim();
          final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text);
          if (!match) {
            return l10n.registerBirthdateFormatError;
          }
          final parsed = DateTime.tryParse(text);
          if (parsed == null) {
            return l10n.registerBirthdateFormatError;
          }
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          if (!parsed.isBefore(todayDate)) {
            return l10n.registerBirthdateFutureError;
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      _buildPrimaryButton(theme, l10n.createAccountAction, _completeRegistration),
      const SizedBox(height: 10),
      Center(
        child: TextButton(
          onPressed: _isLoading ? null : () => setState(() => _currentStep = 1),
          child: Text(l10n.registerBackAction),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final surface = Color.lerp(kSurfaceColor, Colors.white, 0.4)!;
    final topInset = MediaQuery.of(context).padding.top;

    final stepContent = () {
      switch (_currentStep) {
        case 0:
          return _buildStepOne(theme, l10n);
        case 1:
          return _buildStepTwo(theme, l10n);
        case 2:
        default:
          return _buildStepThree(theme, l10n);
      }
    }();

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
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
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
                                    l10n.registerTitle,
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
                          _buildStepIndicator(theme, l10n),
                          const SizedBox(height: 20),
                          ...stepContent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
