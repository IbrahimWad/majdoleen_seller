# Password Reset Feature Integration

## Complete Flow Overview

The password reset feature now follows this complete journey:

```
User enters phone number
          ↓
    [ForgotPasswordScreen]
          ↓
    API: /api/seller/forgot-password/send-otp
          ↓
    Verify 6-digit OTP
[ForgotPasswordVerificationScreen]
          ↓
    API: /api/seller/forgot-password/verify-otp (returns reset_token)
          ↓
    Enter new password & confirmation
    [ResetPasswordScreen]
          ↓
    API: /api/seller/forgot-password/reset
          ↓
    Success → Auto-redirect to Login
```

## Implementation Details

### 1. Forgot Password Screen (Phone Input)
**File**: [lib/screens/forgot_password_screen.dart](lib/screens/forgot_password_screen.dart)

Changed from email to phone number input:
- Takes phone number instead of email
- Validates phone is not empty
- Calls `sendForgotPasswordOtp()` API
- Navigates to verification screen with phone number
- Shows loading state during API call
- Handles errors gracefully

### 2. Forgot Password Verification Screen (OTP Verification)
**File**: [lib/screens/forgot_password_verification_screen.dart](lib/screens/forgot_password_verification_screen.dart)

New screen for OTP verification:
- Displays phone number where code was sent
- 6-digit OTP input field with number-only keyboard
- Validates OTP is 6 digits
- Calls `verifyForgotPasswordOtp()` API
- Receives `reset_token` from API response
- Resend OTP functionality with 60-second countdown
- Navigates to reset password screen with reset token
- Shows loading state and error handling

### 3. Reset Password Screen (Password Reset)
**File**: [lib/screens/reset_password_screen.dart](lib/screens/reset_password_screen.dart)

Complete password reset:
- New password input with show/hide toggle
- Confirm password field with toggle
- Real-time validation (6 char minimum, matching)
- Calls `resetPassword()` API with reset_token
- Success → Auto-redirect to login after 1.5s
- Error handling for expired/invalid tokens
- Back to login navigation option

### 4. Backend API Methods
**File**: [lib/services/seller_auth_service.dart](lib/services/seller_auth_service.dart)

Added three new methods:

#### `sendForgotPasswordOtp(phone)`
```dart
POST /api/seller/forgot-password/send-otp
Body: { "phone": "+966..." }
Response: { "success": true, "message": "...", ... }
```

#### `verifyForgotPasswordOtp(phone, otp)`
```dart
POST /api/seller/forgot-password/verify-otp
Body: { "phone": "+966...", "otp": "123456" }
Response: { "success": true, "reset_token": "...", ... }
```

#### `resetPassword(resetToken, password, passwordConfirmation)`
```dart
POST /api/seller/forgot-password/reset
Body: {
  "reset_token": "...",
  "password": "newpass",
  "password_confirmation": "newpass"
}
Response: { "success": true, "message": "Password updated successfully" }
```

### 5. Routing & Navigation
**Files Modified**:
- [lib/core/app_routes.dart](lib/core/app_routes.dart)
- [lib/app/majdoleen_seller_app.dart](lib/app/majdoleen_seller_app.dart)

Routes:
- `/forgot-password` → ForgotPasswordScreen
- `/forgot-password-verification` → ForgotPasswordVerificationScreen
- `/reset-password` → ResetPasswordScreen

### 6. Localization (English & Arabic)
**File**: [lib/core/app_localizations.dart](lib/core/app_localizations.dart)

#### Forgot Password Screen Strings:
- `forgotPasswordTitle` - "Reset your password"
- `forgotPasswordSubtitle` - "Enter your phone number to receive an OTP."
- `forgotPasswordPhoneRequired` - "Please enter your phone number."
- `forgotPasswordAction` - "Send OTP"
- `forgotPasswordHelper` - "We will send a 6-digit code to your phone."
- `forgotPasswordOtpSent` - "OTP sent successfully. Check your phone."
- `forgotPasswordOtpResent` - "OTP resent. Check your phone."
- `forgotPasswordFailed` - "Failed to send OTP. Please try again."

#### Forgot Password Verification Strings:
- `forgotPasswordVerifyTitle` - "Verify your phone"
- `forgotPasswordVerifySubtitle` - "Enter the 6-digit code we sent to {phone}"
- `forgotPasswordVerifyAction` - "Verify and reset"
- `forgotPasswordVerifyHelper` - "Enter the code to proceed with password reset."
- `forgotPasswordVerifyNoCodePrompt` - "Didn't receive the code?"
- `forgotPasswordResendAction` - "Resend OTP"
- `forgotPasswordResendIn` - "Resend OTP in {seconds}s"
- `forgotPasswordOtpRequired` - "Please enter the 6-digit code."
- `forgotPasswordOtpInvalid` - "Invalid OTP. Please try again."
- `forgotPasswordOtpExpired` - "OTP has expired. Please request a new one."
- `forgotPasswordOtpVerified` - "Code verified. Proceed to reset password."
- `forgotPasswordOtpVerificationFailed` - "OTP verification failed. Please try again."

#### Reset Password Strings:
- `resetPasswordTitle` - "Set new password"
- `resetPasswordSubtitle` - "Enter your new password to regain access."
- `resetPasswordLabel` - "New password"
- `resetPasswordHint` - "Minimum 6 characters"
- `resetPasswordConfirmLabel` - "Confirm password"
- `resetPasswordConfirmHint` - "Re-enter your password"
- `resetPasswordAction` - "Reset password"
- `resetPasswordHelper` - "Your password must be at least 6 characters long."
- `resetPasswordRequired` - "Please enter a password."
- `resetPasswordMinLength` - "Password must be at least 6 characters."
- `resetPasswordConfirmRequired` - "Please confirm your password."
- `resetPasswordMismatch` - "Passwords do not match."
- `resetPasswordSuccess` - "Password reset successfully. Redirecting to login..."
- `resetPasswordFailed` - "Password reset failed. Please try again."
- `resetPasswordInvalidToken` - "Invalid reset token. Please request a new password reset."
- `resetPasswordExpiredToken` - "Reset token has expired. Please request a new password reset."
- `resetPasswordTokenError` - "Token error. Please request a new password reset."
- `resetPasswordBackPrompt` - "Know your password?"
- `resetPasswordBackToLogin` - "Back to login"

## Error Handling

| Error Scenario | Screen | Handling |
|---|---|---|
| Phone number empty | ForgotPasswordScreen | Validation before API call |
| API send OTP fails | ForgotPasswordScreen | Shows error message, allows retry |
| OTP not received | ForgotPasswordVerificationScreen | Resend button with 60s countdown |
| OTP invalid | ForgotPasswordVerificationScreen | Shows error, allows retry |
| OTP expired | ForgotPasswordVerificationScreen | Shows expiration message |
| Invalid reset token | ResetPasswordScreen | Shows error, suggests new reset |
| Reset token expired | ResetPasswordScreen | Shows expiration message |
| Password mismatch | ResetPasswordScreen | Real-time validation |
| Server errors | All | Generic error message with retry |

## User Interface Features

✅ Phone number input with proper keyboard
✅ 6-digit OTP input with number-only keyboard
✅ Show/hide password toggles
✅ Real-time validation feedback
✅ Loading state indicators
✅ Resend OTP functionality with countdown
✅ Consistent design with app theme
✅ Bilingual support (English & Arabic)
✅ RTL/LTR layout support
✅ Wave clipper header with logo
✅ Info boxes with helpful messages
✅ Gradient buttons with shadow effects
✅ Auto-focus management

## Data Flow

```
ForgotPasswordScreen
├── Input: phone number
├── API Call: sendForgotPasswordOtp(phone)
└── Passes: { phone, reset_token(if returned) }
    ↓
ForgotPasswordVerificationScreen
├── Input: 6-digit OTP
├── API Call: verifyForgotPasswordOtp(phone, otp)
├── Response: { reset_token, ... }
└── Passes: { reset_token }
    ↓
ResetPasswordScreen
├── Input: new password, confirm password
├── API Call: resetPassword(resetToken, password, passwordConfirmation)
├── Response: { success: true, message: "..." }
└── Redirect: AppRoutes.login (after 1.5s delay)
```

## API Endpoints Reference

### 1. Send OTP
```
POST /api/seller/forgot-password/send-otp
Content-Type: application/json

Request Body:
{
  "phone": "+966501234567"
}

Success Response (200):
{
  "success": true,
  "message": "OTP sent successfully",
  "reset_token": "optional_token"
}

Error Response (422):
{
  "success": false,
  "error": "Invalid phone number"
}
```

### 2. Verify OTP
```
POST /api/seller/forgot-password/verify-otp
Content-Type: application/json

Request Body:
{
  "phone": "+966501234567",
  "otp": "123456"
}

Success Response (200):
{
  "success": true,
  "reset_token": "token_value",
  "message": "OTP verified successfully"
}

Error Cases:
- 422: { "success": false, "error": "Invalid OTP" }
- 422: { "success": false, "error": "OTP expired" }
```

### 3. Reset Password
```
POST /api/seller/forgot-password/reset
Content-Type: application/json

Request Body:
{
  "reset_token": "token_value",
  "password": "newpassword",
  "password_confirmation": "newpassword"
}

Success Response (200):
{
  "success": true,
  "message": "Password updated successfully"
}

Error Cases:
- 422: { "success": false, "error": "Invalid reset token" }
- 422: { "success": false, "error": "Reset token expired" }
- 422: { "success": false, "error": {...validation errors...} }
- 500: { "success": false, "error": "Password reset failed" }
```

## Testing Checklist

- [ ] Phone number validation works
- [ ] OTP sent successfully and displays correct phone number
- [ ] OTP resend button works with 60-second countdown
- [ ] OTP code validation (6 digits required)
- [ ] Invalid OTP shows error message
- [ ] Valid OTP navigates to reset password screen
- [ ] Password validation (minimum 6 characters)
- [ ] Password mismatch detection
- [ ] Reset password success redirects to login
- [ ] Token expiration errors display correctly
- [ ] Bilingual strings display properly
- [ ] RTL layout works correctly for Arabic
- [ ] Loading states appear during API calls
- [ ] Back navigation works at each screen
- [ ] Network error handling works

## Integration Notes

- All screens follow the existing app design pattern
- Consistent use of LoginField widget for inputs
- Consistent use of LoginWaveClipper for header
- Theme colors maintained (kBrandColor, kInkColor, etc.)
- Localization integrated with existing AppLocalizations
- Navigation uses named routes with arguments
- Error handling follows app conventions with showAppSnackBar
- Loading states use CircularProgressIndicator
- All code is null-safe and properly typed

