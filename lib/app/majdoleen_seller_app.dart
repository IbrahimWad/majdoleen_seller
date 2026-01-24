import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/app_localizations.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/locale_controller.dart';
import '../services/auth_storage.dart';
import '../screens/add_product_screen.dart';
import '../screens/approval_pending_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/forgot_password_verification_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/payouts_screen.dart';
import '../screens/products_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/store_profile_screen.dart';
import '../screens/subscription_plans_screen.dart';
import '../screens/verification_screen.dart';
import '../screens/welcome_screen.dart';

class MajdoleenSellerApp extends StatefulWidget {
  const MajdoleenSellerApp({super.key});

  @override
  State<MajdoleenSellerApp> createState() => _MajdoleenSellerAppState();
}

class _MajdoleenSellerAppState extends State<MajdoleenSellerApp> {
  final LocaleController _localeController = LocaleController();
  final AuthStorage _authStorage = AuthStorage();
  bool _authInitialized = false;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _localeController.load();
    _loadAuthToken();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthToken() async {
    final token = await _authStorage.readToken();
    if (!mounted) return;
    setState(() {
      _hasToken = token != null && token.isNotEmpty;
      _authInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    return LocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          final home = !_localeController.initialized || !_authInitialized
              ? const _StartupLoader()
              : _localeController.locale == null
                  ? LanguageSelectionScreen(
                      deviceLocale: deviceLocale,
                      onSelected: _localeController.setLocale,
                    )
                  : _hasToken
                      ? const HomeScreen()
                      : const WelcomeScreen();

          return MaterialApp(
            title: 'Majdoleen Seller',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            locale: _localeController.locale,
            home: home,
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.verification: (_) => const VerificationScreen(),
        AppRoutes.approvalPending: (_) => const ApprovalPendingScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.forgotPasswordVerification: (_) =>
            const ForgotPasswordVerificationScreen(),
        AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.orders: (_) => const OrdersScreen(),
        AppRoutes.products: (_) => const ProductsScreen(),
        AppRoutes.payouts: (_) => const PayoutsScreen(),
        AppRoutes.statistics: (_) => const StatisticsScreen(),
        AppRoutes.storeProfile: (_) => const StoreProfileScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.subscriptionPlans: (_) => const SubscriptionPlansScreen(),
        AppRoutes.addProduct: (_) => const AddProductScreen(),
      },
          );
        },
      ),
    );
  }
}

class _StartupLoader extends StatelessWidget {
  const _StartupLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
