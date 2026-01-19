import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/majdoleen_seller_app.dart';
import 'core/app_colors.dart';

const String _appCheckDebugToken = 'F5E644D0-0588-4F60-BDE9-C979AAC1CD16';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider(debugToken: _appCheckDebugToken)
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider(debugToken: _appCheckDebugToken)
        : const AppleAppAttestProvider(),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: kSurfaceColor,
      systemNavigationBarDividerColor: kSurfaceColor,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const MajdoleenSellerApp());
}
