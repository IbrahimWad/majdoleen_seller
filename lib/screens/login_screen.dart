import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../services/seller_auth_service.dart';
import '../services/auth_storage.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/login_field.dart';
import '../widgets/login_wave_clipper.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = AppRoutes.login;

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SellerAuthService _sellerAuthService = SellerAuthService();
  final AuthStorage _authStorage = AuthStorage();

  Country? _selectedCountry;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('IQ');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    final rawPhone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (rawPhone.isEmpty || password.isEmpty) {
      showAppSnackBar(context, l10n.loginMissingFields);
      return;
    }

    if (_selectedCountry == null && !rawPhone.startsWith('+')) {
      showAppSnackBar(context, l10n.registerCountryCodeRequired);
      return;
    }

    final phone = _formatPhoneE164();
    if (phone == null) {
      showAppSnackBar(context, l10n.verificationInvalidPhone);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await _sellerAuthService.login(
        phone: phone,
        password: password,
      );
      final accessToken = response['access_token'];
      if (accessToken is String && accessToken.isNotEmpty) {
        await _authStorage.saveToken(accessToken);
      } else {
        debugPrint('Seller login succeeded but no access token was returned.');
        await _authStorage.clearToken();
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e, stackTrace) {
      debugPrint('Seller login failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        showAppSnackBar(context, _loginErrorMessage(e, l10n));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  TextStyle _loginHintStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.bodyMedium;
    final fontSize = (baseStyle?.fontSize ?? 14) * 0.9;
    return (baseStyle ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      color: kInkColor.withOpacity(0.45),
    );
  }

  String _loginErrorMessage(Object error, AppLocalizations l10n) {
    final raw = error.toString().trim();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      final message = raw.substring(prefix.length).trim();
      if (message.isNotEmpty) {
        return message;
      }
    }
    if (raw.isNotEmpty && raw != 'Exception') {
      return raw;
    }
    return l10n.loginFailed;
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
    final hintStyle = _loginHintStyle(theme);

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
              height: 320,
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
                        height: 120,
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
                    const SizedBox(height: 220),
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
                              l10n.loginTitle,
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
                    const SizedBox(height: 28),
                    _buildPhoneWithCountryCode(theme, l10n),
                    const SizedBox(height: 20),
                    LoginField(
                      controller: _passwordController,
                      label: l10n.passwordLabel,
                      hint: l10n.passwordHint,
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: kBrandColor,
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
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
                            const SizedBox(width: 8),
                            Text(
                              l10n.rememberMe,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: kInkColor.withOpacity(0.7),
                                fontSize:
                                    (theme.textTheme.bodyMedium?.fontSize ??
                                            14) *
                                        1.1,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.forgotPassword);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kBrandColor,
                            textStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontSize:
                                  (theme.textTheme.bodyMedium?.fontSize ?? 14) *
                                      1.1,
                              fontWeight: FontWeight.w600,
                              inherit: true,
                            ),
                          ),
                          child: Text(l10n.forgotPassword),
                        ),
                      ],
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
                            onTap: _isLoading ? null : _login,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        l10n.loginAction,
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
                          l10n.noAccountPrompt,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: kInkColor.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.register);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: kBrandColor,
                          ),
                          child: Text(l10n.registerAction),
                        ),
                      ],
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
