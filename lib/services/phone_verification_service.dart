import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  String? _phoneNumber;

  // Send OTP to phone number
  Future<void> sendOTP(String phoneNumber) async {
    _phoneNumber = phoneNumber;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification completed
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 120),
    );
  }

  // Verify OTP and get Firebase token
  Future<String?> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID not found. Please request OTP again.');
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    String? idToken = await userCredential.user?.getIdToken();

    return idToken;
  }

  // Logout from Firebase
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
