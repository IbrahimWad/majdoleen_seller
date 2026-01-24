import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'loginTitle': 'Sign in',
      'loginHeadline': 'Welcome back',
      'loginSubtitle': 'Sign in to keep managing your store.',
      'emailLabel': 'Email',
      'emailHint': 'demo@email.com',
      'addressLabel': 'Address',
      'addressHint': 'Enter your address',
      'phoneLabel': 'Phone number',
      'phoneHint': 'Enter your phone number',
      'passwordLabel': 'Password',
      'passwordHint': 'Enter your password',
      'loginAction': 'Login',
      'loginMissingFields': 'Please enter your phone and password.',
      'loginFailed': 'Login failed.',
      'rememberMe': 'Remember me',
      'forgotPassword': 'Forgot password?',
      'forgotPasswordTitle': 'Reset your password',
      'forgotPasswordSubtitle': 'Enter your phone number to receive an OTP.',
      'forgotPasswordPhoneRequired': 'Please enter your phone number.',
      'forgotPasswordAction': 'Send OTP',
      'forgotPasswordHelper': 'We will send a 6-digit code to your phone.',
      'forgotPasswordRememberPrompt': 'Remembered your password?',
      'forgotPasswordBackToLogin': 'Back to login',
      'forgotPasswordOtpSent': 'OTP sent successfully. Check your phone.',
      'forgotPasswordOtpResent': 'OTP resent. Check your phone.',
      'forgotPasswordFailed': 'Failed to send OTP. Please try again.',
      'forgotPasswordVerifyTitle': 'Verify your phone',
      'forgotPasswordVerifySubtitle': 'Enter the 6-digit code we sent to {phone}',
      'forgotPasswordVerifyAction': 'Verify and reset',
      'forgotPasswordVerifyHelper': 'Enter the code to proceed with password reset.',
      'forgotPasswordVerifyNoCodePrompt': 'Didn\'t receive the code?',
      'forgotPasswordResendAction': 'Resend OTP',
      'forgotPasswordResendIn': 'Resend OTP in {seconds}s',
      'forgotPasswordOtpRequired': 'Please enter the 6-digit code.',
      'forgotPasswordOtpInvalid': 'Invalid OTP. Please try again.',
      'forgotPasswordOtpExpired': 'OTP has expired. Please request a new one.',
      'forgotPasswordOtpVerified': 'Code verified. Proceed to reset password.',
      'forgotPasswordOtpVerificationFailed': 'OTP verification failed. Please try again.',
      'resetPasswordTitle': 'Set new password',
      'resetPasswordSubtitle': 'Enter your new password to regain access.',
      'resetPasswordLabel': 'New password',
      'resetPasswordHint': 'Minimum 6 characters',
      'resetPasswordConfirmLabel': 'Confirm password',
      'resetPasswordConfirmHint': 'Re-enter your password',
      'resetPasswordAction': 'Reset password',
      'resetPasswordHelper': 'Your password must be at least 6 characters long.',
      'resetPasswordRequired': 'Please enter a password.',
      'resetPasswordMinLength': 'Password must be at least 6 characters.',
      'resetPasswordConfirmRequired': 'Please confirm your password.',
      'resetPasswordMismatch': 'Passwords do not match.',
      'resetPasswordSuccess': 'Password reset successfully. Redirecting to login...',
      'resetPasswordFailed': 'Password reset failed. Please try again.',
      'resetPasswordInvalidToken': 'Invalid reset token. Please request a new password reset.',
      'resetPasswordExpiredToken': 'Reset token has expired. Please request a new password reset.',
      'resetPasswordTokenError': 'Token error. Please request a new password reset.',
      'resetPasswordBackPrompt': 'Know your password?',
      'resetPasswordBackToLogin': 'Back to login',
      'noAccountPrompt': 'No account?',
      'registerAction': 'Sign up',
      'registerTitle': 'Register',
      'registerHeadline': 'Create your account',
      'registerSubtitle': 'Join Majdoleen Seller and start selling today.',
      'fullNameLabel': 'Full name',
      'confirmPasswordLabel': 'Confirm password',
      'registerSendOtpAction': 'Send verification code',
      'registerCountryCodeShort': 'Code',
      'registerCountryCodeRequired': 'Please select a country code.',
      'registerTermsPrefix': 'I agree to the ',
      'registerTermsLink': 'terms and conditions',
      'registerTermsSuffix': '.',
      'registerTermsRequired': 'Please accept the terms and conditions.',
      'registerSendOtpFailed': 'Failed to send OTP.',
      'registerVerificationTokenMissing': 'Verification token is missing.',
      'registerCompleteFailed': 'Registration failed.',
      'registerNameRequired': 'Please enter your name.',
      'registerEmailInvalid': 'Please enter a valid email.',
      'registerShopNameLabel': 'Shop name',
      'registerShopNameHint': 'Enter your shop name',
      'registerShopNameRequired': 'Please enter a shop name.',
      'registerShopPhoneLabel': 'Shop phone',
      'registerShopPhoneHint': 'Enter shop contact phone',
      'registerShopUrlLabel': 'Shop URL',
      'registerShopUrlHint': 'Enter shop URL (optional)',
      'registerPasswordRequired': 'Password is required.',
      'registerPasswordMinLength': 'Password must be at least 6 characters.',
      'registerConfirmPasswordRequired': 'Please confirm your password.',
      'registerPasswordMismatch': 'Passwords do not match.',
      'registerGenderLabel': 'Gender',
      'registerGenderHint': 'Select gender',
      'registerGenderMale': 'Male',
      'registerGenderFemale': 'Female',
      'registerGenderOther': 'Other',
      'registerGenderRequired': 'Please select a gender.',
      'registerCityLabel': 'City',
      'registerCityHint': 'Enter your city',
      'registerCityRequired': 'Please enter your city.',
      'registerCityLoading': 'Loading cities...',
      'registerCityEmpty': 'No cities available.',
      'registerCityLoadFailed': 'Could not load cities.',
      'registerBirthdateLabel': 'Birthdate',
      'registerBirthdateHint': 'YYYY-MM-DD',
      'registerBirthdateRequired': 'Please enter your birthdate.',
      'registerBirthdateFormatError': 'Use the format YYYY-MM-DD.',
      'registerBirthdateFutureError': 'Birthdate must be before today.',
      'registerBirthdatePickerTitle': 'Select birthdate',
      'registerOtpInstruction': 'Enter the 6-digit code sent to {phone}',
      'registerOtpSentTo': 'We sent a verification code to {phone}',
      'registerBackAction': 'Back',
      'registerTermsOpenFailed': 'Could not open the terms and conditions.',
      'createAccountAction': 'Create account',
      'alreadyHaveAccountPrompt': 'Already have an account?',
      'loginLink': 'Login',
      'verificationTitle': 'Verify your account',
      'verificationSubtitle': 'Enter the 6-digit code we sent to you.',
      'verificationSentToEmail': 'We sent a 6-digit code to your email.',
      'verificationSentToPhone': 'We sent a 6-digit code to your phone.',
      'verificationCodeLabel': 'Verification code',
      'verificationCodeHint': 'Enter 6-digit code',
      'verificationMethodLabel': 'Send code via',
      'verificationMethodEmail': 'Email',
      'verificationMethodSms': 'SMS',
      'verificationResendPrompt': 'Didn\'t receive it?',
      'verificationResendAction': 'Resend',
      'verificationResendIn': 'Resend in {seconds}s',
      'verificationVerifyAction': 'Verify account',
      'verificationBackToLogin': 'Back to login',
      'verificationCodeRequired': 'Enter the 6-digit code.',
      'verificationResentMessage': 'New code sent.',
      'verificationCompleteMessage': 'Account verified. Welcome!',
      'verificationInvalidCode': 'The code you entered is invalid.',
      'verificationCodeExpired': 'This code has expired. Please request a new one.',
      'verificationTooManyRequests': 'Too many attempts. Try again later.',
      'verificationInvalidPhone': 'Enter a valid phone number.',
      'verificationSmsRegionBlocked':
          'SMS is not enabled for this region. Please contact support.',
      'verificationProviderDisabled': 'Phone sign-in is disabled for this project.',
      'verificationNetworkError': 'Network error. Check your connection and try again.',
      'verificationResendFailed': 'Could not resend the code. Try again.',
      'verificationBackendInvalidToken':
          'Phone verification failed. Please try again.',
      'verificationBackendMissingPhone':
          'Your Firebase account is missing a phone number.',
      'verificationBackendMisconfigured':
          'Verification service is temporarily unavailable.',
      'verificationUnexpectedError': 'Something went wrong. Please try again.',
      'approvalPendingTitle': 'Thanks for registering',
      'approvalPendingSubtitle':
          'Your account is under review. We will send you a WhatsApp message once it is approved.',
      'approvalPendingAction': 'Back to login',
      'welcomeAppName': 'Majdoleen Seller',
      'welcomeSellerAppBadge': 'Seller app',
      'welcomeNext': 'Next',
      'welcomeGetStarted': 'Get started',
      'welcomeSkip': 'Skip',
      'welcomeStepIndicator': 'Step {current} of {total}',
      'welcomeSellerKit': 'Seller kit',
      'welcomeStep1Title': 'Welcome to Majdoleen Seller',
      'welcomeStep1Subtitle':
          'Manage your shop, orders, and inventory in one place.',
      'welcomeStep1Highlight1': 'Dashboard',
      'welcomeStep1Highlight2': 'Inventory',
      'welcomeStep1Highlight3': 'Inbox',
      'welcomeStep2Title': 'Track Orders Easily',
      'welcomeStep2Subtitle':
          'Follow every order from confirmation to delivery.',
      'welcomeStep2Highlight1': 'Live tracking',
      'welcomeStep2Highlight2': 'Courier',
      'welcomeStep2Highlight3': 'Pickup',
      'welcomeStep3Title': 'Grow Your Business',
      'welcomeStep3Subtitle':
          'Reach more customers and grow your sales faster.',
      'welcomeStep3Highlight1': 'Promotions',
      'welcomeStep3Highlight2': 'Payouts',
      'welcomeStep3Highlight3': 'Insights',
      'homeTodaySalesTitle': 'Today sales',
      'homeTodaySalesSubtitle': '12 orders',
      'homePendingOrdersTitle': 'Pending orders',
      'homePendingOrdersSubtitle': 'Need packing',
      'homeAvailableBalanceTitle': 'Available balance',
      'homeAvailableBalanceSubtitle': 'Next payout Fri',
      'homeStoreRatingTitle': 'Store rating',
      'homeStoreRatingSubtitle': '218 reviews',
      'homeTodayOverviewTitle': 'Today overview',
      'homeQuickActionsTitle': 'Quick actions',
      'homeQuickActionsAction': 'Customize',
      'homeNewOrdersTitle': 'New orders',
      'homeViewAllAction': 'View all',
      'homeInventoryAlertsTitle': 'Inventory alerts',
      'homeRestockAction': 'Restock',
      'homeQuickActionAddProduct': 'Add product',
      'homeQuickActionCreateOffer': 'Create offer',
      'homeQuickActionMessageBuyers': 'Message buyers',
      'homeQuickActionRequestPayout': 'Request payout',
      'homeOrderStatusPackaging': 'Packaging',
      'homeOrderStatusReadyForPickup': 'Ready for pickup',
      'homeOrderStatusNewOrder': 'New order',
      'homeOrderTime12MinAgo': '12 min ago',
      'homeOrderTime28MinAgo': '28 min ago',
      'homeOrderTime1HrAgo': '1 hr ago',
      'homeInventoryOnly6Left': 'Only 6 left',
      'homeInventoryLowStock12Left': 'Low stock - 12 left',
      'homeInventoryRestockSoon': 'Restock soon',
      'homeBalanceChangeThisWeek': '+8.2% this week',
      'homeNextPayoutLabel': 'Next payout',
      'homeNextPayoutValue': 'Friday, 10:00',
      'homeOrdersTodayLabel': 'Orders today',
      'homeOrdersTodayValue': '18 total',
      'homeOrderItemsLine': '{count} items - {total}',
      'navOrders': 'Orders',
      'navHome': 'Home',
      'navProducts': 'Products',
      'navPayouts': 'Payouts',
      'navStats': 'Stats',
      'statsTitle': 'Statistics',
      'statsSubtitle': 'Your store performance at a glance.',
      'statsRangeWeek': '7 days',
      'statsRangeMonth': '30 days',
      'statsRangeQuarter': '90 days',
      'statsRangeYear': 'Year',
      'statsOverviewTitle': 'Overview',
      'statsOverviewSubtitle': 'Key metrics from the selected range.',
      'statsTrendTitle': 'Sales trend',
      'statsTrendSubtitle': 'Revenue vs orders',
      'statsTopProductsTitle': 'Top products',
      'statsMetricRevenue': 'Revenue',
      'statsMetricOrders': 'Orders',
      'statsMetricConversion': 'Conversion',
      'statsMetricAvgOrder': 'Avg order',
      'statsMetricCustomers': 'Customers',
      'statsMetricReturnRate': 'Return Rate',
      'statsCategoryTitle': 'Sales by Category',
      'statsCategoryAction': 'View Details',
      'statsMonthlyTitle': 'Monthly Performance',
      'statsMonthlyAction': 'View Report',
      'statsSoldCount': 'Sold {count}',
      'statsShopSnapshotTitle': 'Shop snapshot',
      'statsShopSnapshotSubtitle': 'Quick view of your shop totals.',
      'statsShopSalesTitle': 'Sales & earnings',
      'statsShopSalesSubtitle': 'Totals from your shop performance.',
      'statsShopGrossSalesLabel': 'Gross sales',
      'statsShopPaidSalesLabel': 'Paid sales',
      'statsShopEarningsApprovedLabel': 'Approved earnings',
      'statsShopEarningsPendingLabel': 'Pending earnings',
      'statsShopEarningsRefundedLabel': 'Refunded earnings',
      'statsShopProductsLabel': 'Products',
      'statsShopOrdersLabel': 'Orders',
      'statsShopFollowersLabel': 'Followers',
      'statsShopAvgRatingLabel': 'Avg rating',
      'statsLoadFailed': 'Could not load statistics.',
      'statsNoData': 'No data yet.',
      'productsSearchHint': 'Search by product name or SKU',
      'productsCategoryAll': 'All',
      'productsCategoryClothes': 'Clothes',
      'productsCategoryShoes': 'Shoes',
      'productsCategoryBags': 'Bags',
      'productsCategoryAccessories': 'Accessories',
      'productsFilterAll': 'All',
      'productsFilterActive': 'Active',
      'productsFilterInactive': 'Inactive',
      'productsStockFilterAll': 'All',
      'productsStockFilterLow': 'Low stock',
      'productsStockFilterOut': 'Out of stock',
      'productsSummaryTotal': 'Total products',
      'productsSummaryActive': 'Active',
      'productsSummaryLowStock': 'Low stock',
      'productsListTitle': 'Products ({count})',
      'productsSortNewest': 'Sort: Newest',
      'productsStatusActive': 'Active',
      'productsStatusInactive': 'Inactive',
      'productsStatusDraft': 'Draft',
      'productsStockOut': 'Out of stock',
      'productsStockUnknown': 'Stock • --',
      'productsStockLow': 'Low stock • {count}',
      'productsStockAvailable': 'Stock • {count}',
      'productsQuickActions': 'Quick actions',
      'productsActionToggleStatus': 'Toggle status',
      'productsActionUpdateDiscount': 'Update discount',
      'productsActionUpdatePrice': 'Update price',
      'productsActionUpdateStock': 'Update stock',
      'productsStatusUpdated': 'Status updated.',
      'productsStatusUpdateFailed': 'Status update failed.',
      'productsDiscountDialogTitle': 'Update discount',
      'productsDiscountTypeLabel': 'Discount type',
      'productsDiscountTypeFixed': 'Fixed amount',
      'productsDiscountTypePercent': 'Percent',
      'productsDiscountAmountLabel': 'Discount amount',
      'productsDiscountUpdated': 'Discount updated.',
      'productsDiscountUpdateFailed': 'Discount update failed.',
      'productsPriceDialogTitle': 'Update price',
      'productsPurchasePriceLabel': 'Purchase price',
      'productsUnitPriceLabel': 'Unit price',
      'productsPriceUpdated': 'Price updated.',
      'productsPriceUpdateFailed': 'Price update failed.',
      'productsStockDialogTitle': 'Update stock',
      'productsQuantityLabel': 'Quantity',
      'productsStockUpdated': 'Stock updated.',
      'productsStockUpdateFailed': 'Stock update failed.',
      'productsVariationPriceDialogTitle': 'Update variation prices',
      'productsVariationStockDialogTitle': 'Update variation stock',
      'productsVariationsEmpty': 'No variations found for this product.',
      'productsVariationLabel': 'Variation {index}',
      'productsVariationCodeLabel': 'Variation code',
      'productsAddVariation': 'Add variation',
      'productsVariationsTitle': 'Variations',
      'productsDiscountTitle': 'Discount',
      'productsThumbnailTitle': 'Thumbnail image',
      'productsThumbnailLabel': 'Upload thumbnail',
      'productsPermalinkLabel': 'Permalink',
      'productsTypeLabel': 'Product type',
      'productsTypeSingle': 'Single',
      'productsTypeVariable': 'Variable',
      'productsConditionLabel': 'Condition',
      'productsFormNameRequired': 'Enter a product name.',
      'productsFormPermalinkRequired': 'Enter a permalink.',
      'productsFormVariationRequired': 'Add at least one variation.',
      'productsSaveFailed': 'Product save failed.',
      'productsDeleteFailed': 'Product delete failed.',
      'productsImageTooLarge': 'Image must be smaller than 4MB.',
      'productsImageUploadFailed': 'Image upload failed.',
      'productsLoadFailed': 'Failed to load products.',
      'productsEmptyMessage': 'No products yet.',
      'productsProductId': 'ID',
      'productsUnnamed': 'Unnamed product',
      'addProductTitle': 'Add product',
      'addProductSaveDraft': 'Save draft',
      'addProductDraftSavedMessage': 'Draft saved.',
      'addProductSubmittedMessage': 'Product submitted for review.',
      'addProductStepIndicator': 'Step {current} of {total}',
      'addProductStepBasics': 'Basics',
      'addProductStepPricing': 'Pricing',
      'addProductStepMedia': 'Media',
      'addProductCancel': 'Cancel',
      'addProductBack': 'Back',
      'addProductNext': 'Next',
      'addProductPublish': 'Publish',
      'addProductBasicsTitle': 'Product basics',
      'addProductBasicsSubtitle': 'Add the core product details for your catalog.',
      'addProductNameLabel': 'Product name',
      'addProductSkuLabel': 'SKU',
      'addProductCategoryLabel': 'Category',
      'addProductCategoryPropertiesTitle': 'Category properties',
      'addProductCategoryPropertiesSubtitle':
          'Select the attributes that match this category.',
      'addProductDescriptionLabel': 'Description',
      'addProductTagsTitle': 'Tags',
      'addProductTagBestseller': 'Bestseller',
      'addProductTagNew': 'New',
      'addProductTagOrganic': 'Organic',
      'addProductTagGiftable': 'Giftable',
      'addProductTagLimited': 'Limited',
      'addProductPropertySize': 'Size',
      'addProductPropertyColor': 'Color',
      'addProductPropertyMaterial': 'Material',
      'addProductPropertyFit': 'Fit',
      'addProductPropertyStyle': 'Style',
      'addProductPropertyStrap': 'Strap',
      'addProductPricingTitle': 'Pricing & inventory',
      'addProductPricingSubtitle': 'Set pricing, cost, and stock availability.',
      'addProductPriceLabel': 'Price',
      'addProductCompareLabel': 'Compare at',
      'addProductUnitLabel': 'Unit',
      'addProductUnitPiece': 'Piece',
      'addProductUnitBottle': 'Bottle',
      'addProductUnitBox': 'Box',
      'addProductUnitSet': 'Set',
      'addProductTrackInventory': 'Track inventory',
      'addProductStockQuantity': 'Stock quantity',
      'addProductLowStockAlert': 'Low stock alert',
      'addProductAllowBackorders': 'Allow backorders',
      'addProductFeatureProduct': 'Feature this product',
      'addProductMediaTitle': 'Media & visibility',
      'addProductMediaSubtitle': 'Upload visuals and decide where to sell.',
      'addProductImagesTitle': 'Product images',
      'addProductImageCover': 'Cover',
      'addProductImageLabel': 'Image {index}',
      'addProductImagePickerMessage': 'Image picker is not connected yet.',
      'addProductDeliveryTitle': 'Delivery options',
      'addProductDeliveryCourier': 'Courier',
      'addProductDeliveryPickup': 'Pickup',
      'addProductDeliverySameDay': 'Same-day',
      'addProductPublishToggle': 'Publish to marketplace',
      'addProductPublishNote':
          'Your product will appear in the seller catalog and marketplace once approved.',
      'addProductSizeMini': 'Mini',
      'addProductSizeSmall': 'Small',
      'addProductSizeMedium': 'Medium',
      'addProductSizeLarge': 'Large',
      'addProductColorBlack': 'Black',
      'addProductColorWhite': 'White',
      'addProductColorBeige': 'Beige',
      'addProductColorBlue': 'Blue',
      'addProductColorGreen': 'Green',
      'addProductColorRed': 'Red',
      'addProductColorBrown': 'Brown',
      'addProductColorGray': 'Gray',
      'addProductColorNavy': 'Navy',
      'addProductColorOlive': 'Olive',
      'addProductColorGold': 'Gold',
      'addProductColorSilver': 'Silver',
      'addProductColorRose': 'Rose',
      'addProductColorPearl': 'Pearl',
      'addProductMaterialCotton': 'Cotton',
      'addProductMaterialLinen': 'Linen',
      'addProductMaterialSilk': 'Silk',
      'addProductMaterialDenim': 'Denim',
      'addProductMaterialWool': 'Wool',
      'addProductMaterialLeather': 'Leather',
      'addProductMaterialSuede': 'Suede',
      'addProductMaterialCanvas': 'Canvas',
      'addProductMaterialSynthetic': 'Synthetic',
      'addProductMaterialNylon': 'Nylon',
      'addProductMaterialMetal': 'Metal',
      'addProductMaterialFabric': 'Fabric',
      'addProductMaterialResin': 'Resin',
      'addProductFitSlim': 'Slim',
      'addProductFitRegular': 'Regular',
      'addProductFitRelaxed': 'Relaxed',
      'addProductFitOversized': 'Oversized',
      'addProductStyleSneaker': 'Sneaker',
      'addProductStyleLoafer': 'Loafer',
      'addProductStyleBoot': 'Boot',
      'addProductStyleHeel': 'Heel',
      'addProductStyleSandal': 'Sandal',
      'addProductStyleMinimal': 'Minimal',
      'addProductStyleStatement': 'Statement',
      'addProductStyleClassic': 'Classic',
      'addProductStyleModern': 'Modern',
      'addProductStrapShort': 'Short',
      'addProductStrapLong': 'Long',
      'addProductStrapAdjustable': 'Adjustable',
      'editProductTitle': 'Edit product',
      'editProductSaveAction': 'Save changes',
      'editProductDeleteAction': 'Delete',
      'editProductDeleteTitle': 'Delete product?',
      'editProductDeleteMessage': 'This action cannot be undone.',
      'editProductDeleteCancel': 'Cancel',
      'editProductDeleteConfirm': 'Delete',
      'editProductUpdatedMessage': 'Product updated.',
      'editProductDeletedMessage': 'Product deleted.',
      'drawerStoreProfileTitle': 'Store profile',
      'drawerStoreProfileSubtitle': 'Manage store details',
      'drawerSettingsTitle': 'Settings',
      'drawerSettingsSubtitle': 'Preferences and security',
      'drawerSupportTitle': 'Support',
      'drawerSupportSubtitle': 'Get help and feedback',
      'drawerActive': 'Active',
      'drawerLogOut': 'Log out',
      'drawerLogOutTitle': 'Log out',
      'drawerLogOutMessage':
          'Are you sure you want to log out of Majdoleen Seller?',
      'drawerCancel': 'Cancel',
      'drawerComingSoon': '{label} is coming soon.',
      'storeProfileTitle': 'Store profile',
      'storeProfileSubtitle': 'Update how your shop appears to buyers.',
      'storeProfileLogoTitle': 'Store logo',
      'storeProfileLogoHint': 'Recommended 512x512 PNG',
      'storeProfileLogoUpdateAction': 'Update logo',
      'storeProfileBannerLabel': 'Store banner',
      'storeProfileBannerUpdateAction': 'Update banner',
      'storeProfileDetailsTitle': 'Store details',
      'storeProfileNameLabel': 'Store name',
      'storeProfileNameHint': 'Enter shop name',
      'storeProfileSlugLabel': 'Shop slug',
      'storeProfileSlugHint': 'your-shop',
      'storeProfileTaglineLabel': 'Tagline',
      'storeProfileDescriptionLabel': 'Description',
      'storeProfileCategoryLabel': 'Category',
      'storeProfileContactTitle': 'Contact & location',
      'storeProfileSellerPhoneLabel': 'Seller phone',
      'storeProfileSellerPhoneHint': 'Enter seller phone',
      'storeProfileShopPhoneLabel': 'Shop phone',
      'storeProfileShopPhoneHint': 'Enter shop phone',
      'storeProfilePhoneLabel': 'Phone',
      'storeProfileEmailLabel': 'Email',
      'storeProfileAddressLabel': 'Address',
      'storeProfileAddressHint': 'Enter shop address',
      'storeProfileSeoTitle': 'SEO settings',
      'storeProfileMetaTitleLabel': 'Meta title',
      'storeProfileMetaTitleHint': 'Enter meta title',
      'storeProfileMetaDescriptionLabel': 'Meta description',
      'storeProfileMetaDescriptionHint': 'Enter meta description',
      'storeProfileMetaImageLabel': 'Meta image',
      'storeProfileMetaImageUpdateAction': 'Update image',
      'storeProfileStatusTitle': 'Store status',
      'storeProfileStatusOpenTitle': 'Shop active',
      'storeProfileStatusOpenSubtitle': 'Show your shop as active to buyers',
      'storeProfileStatusAcceptingTitle': 'Accepting orders',
      'storeProfileStatusAcceptingSubtitle': 'Allow new orders to be placed',
      'storeProfileStatusVacationTitle': 'Vacation mode',
      'storeProfileStatusVacationSubtitle': 'Pause ordering for a set period',
      'storeProfileStatusVacationNotice':
          'Vacation mode is on. Buyers cannot place new orders.',
      'storeProfileFulfillmentTitle': 'Fulfillment',
      'storeProfilePickupTitle': 'Pickup',
      'storeProfilePickupSubtitle': 'Allow customers to pick up orders',
      'storeProfileDeliveryTitle': 'Delivery',
      'storeProfileDeliverySubtitle': 'Offer delivery service for the store',
      'storeProfilePrepTimeLabel': 'Order prep time',
      'storeProfileBusinessHoursTitle': 'Business hours',
      'storeProfilePreviewAction': 'Preview',
      'storeProfileSaveAction': 'Save changes',
      'storeProfileSavedMessage': 'Store profile saved.',
      'storeProfilePreviewMessage': 'Preview is coming soon.',
      'storeProfileImageUpdatedMessage': 'Shop image updated.',
      'storeProfileImageUpdateFailed': 'Could not update shop image.',
      'storeProfileImagePickFailed': 'Could not select image.',
      'storeProfileImageTooLarge': 'Image must be 4 MB or less.',
      'storeProfileAuthRequired': 'Please sign in to manage your shop.',
      'storeProfileLoadFailed': 'Could not load shop details.',
      'storeProfileUpdateFailed': 'Shop update failed.',
      'storeProfileNameRequired': 'Please enter a shop name.',
      'storeProfileShopPhoneRequired': 'Please enter a shop phone.',
      'storeProfileSlugRequired': 'Please enter a shop slug.',
      'storeProfileCategorySkincare': 'Skincare',
      'storeProfileCategoryFragrance': 'Fragrance',
      'storeProfileCategoryBeauty': 'Beauty',
      'storeProfileCategoryAccessories': 'Accessories',
      'storeProfilePrepSameDay': 'Same day',
      'storeProfilePrep1to2Days': '1-2 days',
      'storeProfilePrep3to5Days': '3-5 days',
      'storeProfileDayMon': 'Mon',
      'storeProfileDayTue': 'Tue',
      'storeProfileDayWed': 'Wed',
      'storeProfileDayThu': 'Thu',
      'storeProfileDayFri': 'Fri',
      'storeProfileDaySat': 'Sat',
      'storeProfileDaySun': 'Sun',
      'storeProfileHoursRegular': '9:00 AM - 9:00 PM',
      'storeProfileHoursLate': '9:00 AM - 10:00 PM',
      'storeProfileHoursFriday': '2:00 PM - 11:00 PM',
      'storeProfileHoursWeekend': '10:00 AM - 10:00 PM',
      'storeProfileHoursClosed': 'Closed',
      'settingsTitle': 'Settings',
      'settingsSubtitle': 'Manage alerts, preferences, and security.',
      'settingsNotificationsTitle': 'Notifications',
      'settingsOrderUpdatesTitle': 'Order updates',
      'settingsOrderUpdatesSubtitle': 'New orders, cancellations, and refunds',
      'settingsPayoutUpdatesTitle': 'Payout updates',
      'settingsPayoutUpdatesSubtitle': 'Transfers, holds, and failed payouts',
      'settingsLowStockAlertsTitle': 'Low stock alerts',
      'settingsLowStockAlertsSubtitle': 'Reminders when inventory is low',
      'settingsMarketingUpdatesTitle': 'Marketing updates',
      'settingsMarketingUpdatesSubtitle': 'Product tips and seasonal campaigns',
      'settingsSecurityTitle': 'Security',
      'settingsTwoFactorTitle': 'Two-factor authentication',
      'settingsTwoFactorSubtitle': 'Require a one-time code at sign in',
      'settingsBiometricTitle': 'Biometric login',
      'settingsBiometricSubtitle': 'Use fingerprint to access the app',
      'settingsChangePasswordTitle': 'Change password',
      'settingsChangePasswordSubtitle': 'Update your password regularly',
      'settingsPasswordComingSoonMessage': 'Password update coming soon.',
      'settingsPreferencesTitle': 'Preferences',
      'settingsLanguageLabel': 'Language',
      'settingsCurrencyLabel': 'Currency',
      'settingsTimeZoneLabel': 'Time zone',
      'settingsLanguageEnglish': 'English',
      'settingsLanguageArabic': 'Arabic',
      'settingsAccountTitle': 'Account',
      'settingsTeamMembersTitle': 'Team members',
      'settingsTeamMembersSubtitle': 'Invite and manage staff accounts',
      'settingsTeamComingSoonMessage': 'Team settings coming soon.',
      'settingsBillingTitle': 'Billing',
      'settingsBillingSubtitle': 'Invoices and payout statements',
      'settingsBillingComingSoonMessage': 'Billing coming soon.',
      'settingsHelpCenterTitle': 'Help center',
      'settingsHelpCenterSubtitle': 'Get help and support resources',
      'settingsHelpCenterComingSoonMessage': 'Help center coming soon.',
      'settingsPlansTitle': 'Subscription plans',
      'settingsPlansSubtitle': 'Compare tiers and upgrade your store',
      'subscriptionPlansTitle': 'Subscription plans',
      'subscriptionPlansSubtitle': 'Choose the plan that matches your store size.',
      'subscriptionPlansSectionTitle': 'Plan options',
      'subscriptionCurrentLabel': 'Current plan',
      'subscriptionRecommendedBadge': 'Best value',
      'subscriptionFreeName': 'Free',
      'subscriptionPlusName': 'Plus',
      'subscriptionProName': 'Pro',
      'subscriptionFreeDescription': 'For early-stage sellers',
      'subscriptionPlusDescription': 'For growing catalogs',
      'subscriptionProDescription': 'For high-volume teams',
      'subscriptionFreePrice': 'Free',
      'subscriptionPlusPrice': 'SAR 79',
      'subscriptionProPrice': 'SAR 199',
      'subscriptionPerMonth': 'per month',
      'subscriptionForever': 'forever',
      'subscriptionProductsLimit': 'Up to {count} products',
      'subscriptionItemsLimit': 'Up to {count} items',
      'subscriptionProductsUnlimited': 'Unlimited products',
      'subscriptionItemsUnlimited': 'Unlimited items',
      'subscriptionBasicAnalytics': 'Basic analytics',
      'subscriptionAdvancedAnalytics': 'Advanced analytics',
      'subscriptionCustomInsights': 'Custom insights',
      'subscriptionEmailSupport': 'Email support',
      'subscriptionPrioritySupport': 'Priority support',
      'subscriptionDedicatedSuccess': 'Dedicated success',
      'subscriptionChooseAction': 'Choose plan',
      'subscriptionCurrentAction': 'Current plan',
      'subscriptionChangeMessage': 'Plan changes coming soon.',
      'subscriptionCurrentSummary': 'You\'re on the {plan} plan.',
      'subscriptionCurrentHint': 'Upgrade anytime to unlock higher limits.',
      'subscriptionFooterNote': 'Plans renew automatically. Cancel anytime.',
      'subscriptionConfirmTitle': 'Switch to {plan}?',
      'subscriptionConfirmSubtitle': 'Your new limits apply immediately.',
      'subscriptionConfirmAction': 'Confirm plan',
      'subscriptionUpdatedMessage': 'Plan updated to {plan}.',
      'ordersSearchHint': 'Search by order ID or customer',
      'ordersFilterTitle': 'Filter orders',
      'ordersFilterPaymentTitle': 'Payment',
      'ordersFilterDeliveryTitle': 'Delivery',
      'ordersFilterPayoutTitle': 'Payout status',
      'ordersFilterLocationTitle': 'Location',
      'ordersFilterPriorityOnly': 'Priority orders only',
      'ordersFilterClearAction': 'Clear',
      'ordersFilterApplyAction': 'Apply',
      'ordersFilterAll': 'All',
      'ordersEmptyFiltered': 'No orders match the current filters.',
      'ordersEmpty': 'No orders available yet.',
      'ordersLoadFailed': 'Unable to load orders.',
      'ordersCountersFailed': 'Unable to load order counts.',
      'ordersListTitle': 'Orders ({count})',
      'ordersSortLatest': 'Sort: Latest',
      'ordersPriorityBadge': 'Priority',
      'ordersStatusNew': 'New',
      'ordersStatusPending': 'Pending',
      'ordersStatusProcessing': 'Processing',
      'ordersStatusReady': 'Ready',
      'ordersStatusReadyToShip': 'Ready to ship',
      'ordersStatusShipped': 'Shipped',
      'ordersStatusDelivered': 'Delivered',
      'ordersStatusCancelled': 'Cancelled',
      'ordersPaymentCard': 'Card',
      'ordersPaymentCash': 'Cash',
      'ordersPaymentWallet': 'Wallet',
      'ordersPaymentStatusPaid': 'Paid',
      'ordersPaymentStatusUnpaid': 'Unpaid',
      'ordersPaymentStatusRefunded': 'Refunded',
      'ordersPaymentCashOnDelivery': 'Cash on delivery',
      'ordersPaymentCombined': '{method} • {status}',
      'ordersDeliveryCourier': 'Courier',
      'ordersDeliveryPickup': 'Pickup',
      'ordersPayoutPending': 'Pending payout',
      'ordersPayoutHold': 'Payout hold',
      'ordersPayoutScheduled': 'Scheduled',
      'ordersPayoutPaid': 'Paid out',
      'ordersPayoutRefunded': 'Refunded',
      'ordersLocationRiyadh': 'Riyadh',
      'ordersLocationDiriyah': 'Diriyah',
      'ordersItemsLine': '{count} items • {total}',
      'ordersItemsCount': '{count} items',
      'ordersTimeMinutesAgo': '{count} min ago',
      'ordersTimeHoursAgo': '{count} hrs ago',
      'ordersUnknownCustomer': 'Unknown customer',
      'ordersDetailsTitle': 'Order details',
      'ordersDetailsLoadFailed': 'Unable to load order details.',
      'ordersDetailsSummaryTitle': 'Order summary',
      'ordersDetailsCustomerLabel': 'Customer',
      'ordersDetailsItemsLabel': 'Items',
      'ordersDetailsItemsTitle': 'Order items',
      'ordersDetailsItemQuantity': 'Qty: {count}',
      'ordersDetailsItemUnitPrice': 'Unit: {price}',
      'ordersDetailsOptionSize': 'Size',
      'ordersDetailsOptionColor': 'Color',
      'ordersDetailsTotalLabel': 'Total',
      'ordersDetailsPaymentLabel': 'Payment',
      'ordersDetailsDeliveryLabel': 'Delivery',
      'ordersDetailsPayoutLabel': 'Payout',
      'ordersDetailsLocationLabel': 'Location',
      'ordersDetailsPlacedLabel': 'Placed',
      'ordersDetailsStatusTitle': 'Update status',
      'ordersDetailsPriorityToggle': 'Mark as priority',
      'ordersDetailsAssignmentTitle': 'Delivery assignment',
      'ordersDetailsDeliveryCompanyLabel': 'Delivery company',
      'ordersDetailsAssignmentHint': 'Assign to a delivery partner',
      'ordersDetailsAssignmentUnassigned': 'Unassigned',
      'ordersDetailsAssignmentPickupNote':
          'Pickup orders do not require a delivery partner.',
      'ordersDetailsNotesTitle': 'Internal notes',
      'ordersDetailsNotesHint': 'Add notes for your team',
      'ordersDetailsSaveAction': 'Save changes',
      'ordersDetailsSavedMessage': 'Order updated.',
      'ordersDetailsRejectAction': 'Cancel order',
      'ordersDetailsRejectTitle': 'Cancel this order?',
      'ordersDetailsRejectMessage':
          'This will cancel the order for the customer.',
      'ordersDetailsRejectCancel': 'Keep order',
      'ordersDetailsRejectConfirm': 'Cancel order',
      'ordersDetailsRejectedMessage': 'Order cancelled.',
      'ordersStatusUpdateFailed': 'Unable to update order status.',
      'ordersAcceptAction': 'Accept order',
      'ordersAcceptSuccess': 'Order accepted.',
      'ordersAcceptFailed': 'Unable to accept order.',
      'ordersCancelSuccess': 'Order cancelled.',
      'ordersCancelFailed': 'Unable to cancel order.',
      'ordersStatusInvalidDeliveredUnpaid':
          'Cannot mark delivered while payment is unpaid.',
      'ordersDetailsDeliveryPartnerFalcon': 'Falcon Logistics',
      'ordersDetailsDeliveryPartnerSwift': 'SwiftExpress',
      'ordersDetailsDeliveryPartnerDesertGo': 'DesertGo',
    },
    'ar': {
      'loginTitle': 'تسجيل الدخول',
      'loginHeadline': 'أهلاً بعودتك',
      'loginSubtitle': 'سجّل الدخول لإدارة متجرك.',
      'emailLabel': 'البريد الإلكتروني',
      'emailHint': 'demo@email.com',
      'addressLabel': 'العنوان',
      'addressHint': 'أدخل العنوان',
      'phoneLabel': 'رقم الهاتف',
      'phoneHint': 'أدخل رقم الهاتف',
      'passwordLabel': 'كلمة المرور',
      'passwordHint': 'أدخل كلمة المرور',
      'loginAction': 'تسجيل الدخول',
      'loginMissingFields': 'يرجى إدخال رقم الهاتف وكلمة المرور.',
      'loginFailed': 'فشل تسجيل الدخول.',
      'rememberMe': 'تذكرني',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'forgotPasswordTitle': 'استعادة كلمة المرور',
      'forgotPasswordSubtitle': 'أدخل رقم هاتفك لاستقبال رمز التحقق.',
      'forgotPasswordPhoneRequired': 'يرجى إدخال رقم الهاتف.',
      'forgotPasswordAction': 'إرسال الرمز',
      'forgotPasswordHelper': 'سنرسل رمز 6 أرقام إلى هاتفك.',
      'forgotPasswordRememberPrompt': 'تذكرت كلمة المرور؟',
      'forgotPasswordBackToLogin': 'العودة لتسجيل الدخول',
      'forgotPasswordOtpSent': 'تم إرسال الرمز بنجاح. تحقق من هاتفك.',
      'forgotPasswordOtpResent': 'تم إعادة إرسال الرمز. تحقق من هاتفك.',
      'forgotPasswordFailed': 'فشل إرسال الرمز. يرجى المحاولة مرة أخرى.',
      'forgotPasswordVerifyTitle': 'تحقق من رقم هاتفك',
      'forgotPasswordVerifySubtitle': 'أدخل رمز الـ 6 أرقام الذي أرسلناه إلى {phone}',
      'forgotPasswordVerifyAction': 'التحقق وتعيين كلمة مرور جديدة',
      'forgotPasswordVerifyHelper': 'أدخل الرمز للمتابعة مع إعادة تعيين كلمة المرور.',
      'forgotPasswordVerifyNoCodePrompt': 'لم تستقبل الرمز؟',
      'forgotPasswordResendAction': 'إعادة إرسال الرمز',
      'forgotPasswordResendIn': 'إعادة إرسال الرمز في {seconds}ث',
      'forgotPasswordOtpRequired': 'يرجى إدخال رمز الـ 6 أرقام.',
      'forgotPasswordOtpInvalid': 'رمز غير صحيح. يرجى المحاولة مرة أخرى.',
      'forgotPasswordOtpExpired': 'انتهت صلاحية الرمز. يرجى طلب رمز جديد.',
      'forgotPasswordOtpVerified': 'تم التحقق من الرمز. انتقل إلى تعيين كلمة المرور.',
      'forgotPasswordOtpVerificationFailed': 'فشل التحقق من الرمز. يرجى المحاولة مرة أخرى.',
      'resetPasswordTitle': 'تعيين كلمة المرور الجديدة',
      'resetPasswordSubtitle': 'أدخل كلمة المرور الجديدة للوصول إلى حسابك.',
      'resetPasswordLabel': 'كلمة المرور الجديدة',
      'resetPasswordHint': 'حد أدنى 6 أحرف',
      'resetPasswordConfirmLabel': 'تأكيد كلمة المرور',
      'resetPasswordConfirmHint': 'أعد إدخال كلمة المرور',
      'resetPasswordAction': 'تعيين كلمة المرور',
      'resetPasswordHelper': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.',
      'resetPasswordRequired': 'يرجى إدخال كلمة المرور.',
      'resetPasswordMinLength': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.',
      'resetPasswordConfirmRequired': 'يرجى تأكيد كلمة المرور.',
      'resetPasswordMismatch': 'كلمات المرور غير متطابقة.',
      'resetPasswordSuccess': 'تم تعيين كلمة المرور بنجاح. جاري إعادة التوجيه إلى تسجيل الدخول...',
      'resetPasswordFailed': 'فشل تعيين كلمة المرور. يرجى المحاولة مرة أخرى.',
      'resetPasswordInvalidToken': 'رمز غير صحيح. يرجى طلب تعيين كلمة مرور جديد.',
      'resetPasswordExpiredToken': 'انتهت صلاحية رمز التعيين. يرجى طلب تعيين كلمة مرور جديد.',
      'resetPasswordTokenError': 'خطأ في الرمز. يرجى طلب تعيين كلمة مرور جديد.',
      'resetPasswordBackPrompt': 'هل تتذكر كلمة المرور؟',
      'resetPasswordBackToLogin': 'العودة لتسجيل الدخول',
      'noAccountPrompt': 'ليس لديك حساب؟',
      'registerAction': 'إنشاء حساب',
      'registerTitle': 'إنشاء حساب',
      'registerHeadline': 'أنشئ حسابك',
      'registerSubtitle': 'انضم إلى Majdoleen Seller وابدأ البيع اليوم.',
      'fullNameLabel': 'الاسم الكامل',
      'confirmPasswordLabel': 'تأكيد كلمة المرور',
      'registerSendOtpAction': 'إرسال رمز التحقق',
      'registerCountryCodeShort': 'الكود',
      'registerCountryCodeRequired': 'يرجى اختيار رمز الدولة.',
      'registerTermsPrefix': 'أوافق على ',
      'registerTermsLink': 'الشروط والأحكام',
      'registerTermsSuffix': '.',
      'registerTermsRequired': 'يرجى الموافقة على الشروط والأحكام.',
      'registerSendOtpFailed': 'تعذر إرسال رمز التحقق.',
      'registerVerificationTokenMissing': 'رمز التحقق مفقود.',
      'registerCompleteFailed': 'فشل إكمال التسجيل.',
      'registerNameRequired': 'يرجى إدخال الاسم.',
      'registerEmailInvalid': 'يرجى إدخال بريد إلكتروني صحيح.',
      'registerShopNameLabel': 'اسم المتجر',
      'registerShopNameHint': 'أدخل اسم المتجر',
      'registerShopNameRequired': 'يرجى إدخال اسم المتجر.',
      'registerShopPhoneLabel': 'هاتف المتجر',
      'registerShopPhoneHint': 'أدخل هاتف التواصل للمتجر',
      'registerShopUrlLabel': 'رابط المتجر',
      'registerShopUrlHint': 'أدخل رابط المتجر (اختياري)',
      'registerPasswordRequired': 'كلمة المرور مطلوبة.',
      'registerPasswordMinLength': 'يجب ألا تقل كلمة المرور عن 6 أحرف.',
      'registerConfirmPasswordRequired': 'يرجى تأكيد كلمة المرور.',
      'registerPasswordMismatch': 'كلمتا المرور غير متطابقتين.',
      'registerGenderLabel': 'الجنس',
      'registerGenderHint': 'اختر الجنس',
      'registerGenderMale': 'ذكر',
      'registerGenderFemale': 'أنثى',
      'registerGenderOther': 'آخر',
      'registerGenderRequired': 'يرجى اختيار الجنس.',
      'registerCityLabel': 'المدينة',
      'registerCityHint': 'أدخل مدينتك',
      'registerCityRequired': 'يرجى إدخال المدينة.',
      'registerCityLoading': 'جارٍ تحميل المدن...',
      'registerCityEmpty': 'لا توجد مدن متاحة.',
      'registerCityLoadFailed': 'تعذر تحميل المدن.',
      'registerBirthdateLabel': 'تاريخ الميلاد',
      'registerBirthdateHint': 'YYYY-MM-DD',
      'registerBirthdateRequired': 'يرجى إدخال تاريخ الميلاد.',
      'registerBirthdateFormatError': 'استخدم الصيغة YYYY-MM-DD.',
      'registerBirthdateFutureError': 'يجب أن يكون تاريخ الميلاد قبل اليوم.',
      'registerBirthdatePickerTitle': 'اختر تاريخ الميلاد',
      'registerOtpInstruction': 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى {phone}',
      'registerOtpSentTo': 'أرسلنا رمز تحقق إلى {phone}',
      'registerBackAction': 'رجوع',
      'registerTermsOpenFailed': 'تعذر فتح صفحة الشروط والأحكام.',
      'createAccountAction': 'إنشاء حساب',
      'alreadyHaveAccountPrompt': 'لديك حساب بالفعل؟',
      'loginLink': 'تسجيل الدخول',
      'verificationTitle': 'تأكيد حسابك',
      'verificationSubtitle': 'أدخل الرمز المكوّن من 6 أرقام الذي أرسلناه إليك.',
      'verificationSentToEmail':
          'أرسلنا رمزًا من 6 أرقام إلى بريدك الإلكتروني.',
      'verificationSentToPhone': 'أرسلنا رمزًا من 6 أرقام إلى هاتفك.',
      'verificationCodeLabel': 'رمز التحقق',
      'verificationCodeHint': 'أدخل رمزًا من 6 أرقام',
      'verificationMethodLabel': 'إرسال الرمز عبر',
      'verificationMethodEmail': 'البريد الإلكتروني',
      'verificationMethodSms': 'رسالة نصية',
      'verificationResendPrompt': 'لم يصلك الرمز؟',
      'verificationResendAction': 'إعادة الإرسال',
      'verificationResendIn': 'إعادة الإرسال بعد {seconds} ث',
      'verificationVerifyAction': 'تأكيد الحساب',
      'verificationBackToLogin': 'العودة لتسجيل الدخول',
      'verificationCodeRequired': 'أدخل الرمز المكوّن من 6 أرقام.',
      'verificationResentMessage': 'تم إرسال رمز جديد.',
      'verificationCompleteMessage': 'تم تأكيد الحساب. أهلاً بك!',
      'verificationInvalidCode': 'رمز التحقق غير صحيح.',
      'verificationCodeExpired': 'انتهت صلاحية الرمز. أعد الإرسال.',
      'verificationTooManyRequests': 'محاولات كثيرة. حاول لاحقًا.',
      'verificationInvalidPhone': 'أدخل رقم هاتف صحيحًا.',
      'verificationSmsRegionBlocked':
          'خدمة الرسائل غير مفعلة لهذه المنطقة. تواصل مع الدعم.',
      'verificationProviderDisabled': 'تسجيل الدخول عبر الهاتف غير مفعّل للمشروع.',
      'verificationNetworkError': 'مشكلة في الاتصال. حاول مجددًا.',
      'verificationResendFailed': 'تعذر إعادة إرسال الرمز.',
      'verificationBackendInvalidToken': 'فشل التحقق من الهاتف. حاول مجددًا.',
      'verificationBackendMissingPhone': 'رقم الهاتف غير موجود في حساب Firebase.',
      'verificationBackendMisconfigured': 'خدمة التحقق غير متاحة حاليًا.',
      'verificationUnexpectedError': 'حدث خطأ غير متوقع. حاول مرة أخرى.',
      'approvalPendingTitle': 'شكرًا لتسجيلك',
      'approvalPendingSubtitle':
          'حسابك قيد المراجعة. سنرسل لك رسالة عبر واتساب عند الموافقة.',
      'approvalPendingAction': 'العودة لتسجيل الدخول',
      'welcomeAppName': 'Majdoleen Seller',
      'welcomeSellerAppBadge': 'تطبيق البائع',
      'welcomeNext': 'التالي',
      'welcomeGetStarted': 'ابدأ الآن',
      'welcomeSkip': 'تخطي',
      'welcomeStepIndicator': 'الخطوة {current} من {total}',
      'welcomeSellerKit': 'حزمة البائع',
      'welcomeStep1Title': 'مرحباً بك في Majdoleen Seller',
      'welcomeStep1Subtitle': 'أدر متجرك وطلباتك ومخزونك في مكان واحد.',
      'welcomeStep1Highlight1': 'لوحة التحكم',
      'welcomeStep1Highlight2': 'المخزون',
      'welcomeStep1Highlight3': 'الوارد',
      'welcomeStep2Title': 'تتبع الطلبات بسهولة',
      'welcomeStep2Subtitle': 'تابع كل طلب من التأكيد حتى التسليم.',
      'welcomeStep2Highlight1': 'تتبع مباشر',
      'welcomeStep2Highlight2': 'شركة الشحن',
      'welcomeStep2Highlight3': 'الاستلام',
      'welcomeStep3Title': 'طور عملك',
      'welcomeStep3Subtitle':
          'صل إلى مزيد من العملاء وزد مبيعاتك بسرعة أكبر.',
      'welcomeStep3Highlight1': 'العروض',
      'welcomeStep3Highlight2': 'التحويلات',
      'welcomeStep3Highlight3': 'رؤى',
      'homeTodaySalesTitle': 'مبيعات اليوم',
      'homeTodaySalesSubtitle': '12 طلب',
      'homePendingOrdersTitle': 'طلبات معلقة',
      'homePendingOrdersSubtitle': 'بحاجة للتجهيز',
      'homeAvailableBalanceTitle': 'الرصيد المتاح',
      'homeAvailableBalanceSubtitle': 'الدفعة القادمة الجمعة',
      'homeStoreRatingTitle': 'تقييم المتجر',
      'homeStoreRatingSubtitle': '218 مراجعة',
      'homeTodayOverviewTitle': 'ملخص اليوم',
      'homeQuickActionsTitle': 'إجراءات سريعة',
      'homeQuickActionsAction': 'تخصيص',
      'homeNewOrdersTitle': 'طلبات جديدة',
      'homeViewAllAction': 'عرض الكل',
      'homeInventoryAlertsTitle': 'تنبيهات المخزون',
      'homeRestockAction': 'إعادة التزويد',
      'homeQuickActionAddProduct': 'إضافة منتج',
      'homeQuickActionCreateOffer': 'إنشاء عرض',
      'homeQuickActionMessageBuyers': 'مراسلة العملاء',
      'homeQuickActionRequestPayout': 'طلب تحويل',
      'homeOrderStatusPackaging': 'قيد التجهيز',
      'homeOrderStatusReadyForPickup': 'جاهز للاستلام',
      'homeOrderStatusNewOrder': 'طلب جديد',
      'homeOrderTime12MinAgo': 'قبل 12 دقيقة',
      'homeOrderTime28MinAgo': 'قبل 28 دقيقة',
      'homeOrderTime1HrAgo': 'قبل ساعة',
      'homeInventoryOnly6Left': 'تبقى 6 فقط',
      'homeInventoryLowStock12Left': 'مخزون منخفض - 12 متبقي',
      'homeInventoryRestockSoon': 'إعادة التزويد قريبًا',
      'homeBalanceChangeThisWeek': '+8.2% هذا الأسبوع',
      'homeNextPayoutLabel': 'الدفعة القادمة',
      'homeNextPayoutValue': 'الجمعة، 10:00',
      'homeOrdersTodayLabel': 'طلبات اليوم',
      'homeOrdersTodayValue': 'الإجمالي 18',
      'homeOrderItemsLine': '{count} عناصر - {total}',
      'navOrders': 'الطلبات',
      'navHome': 'الرئيسية',
      'navProducts': 'المنتجات',
      'navPayouts': 'المدفوعات',
      'navStats': 'الإحصائيات',
      'statsTitle': 'الإحصائيات',
      'statsSubtitle': 'نظرة سريعة على أداء متجرك.',
      'statsRangeWeek': '7 أيام',
      'statsRangeMonth': '30 يومًا',
      'statsRangeQuarter': '90 يومًا',
      'statsRangeYear': 'سنة',
      'statsOverviewTitle': 'الملخص',
      'statsOverviewSubtitle': 'أهم المؤشرات للفترة المحددة.',
      'statsTrendTitle': 'منحنى المبيعات',
      'statsTrendSubtitle': 'الإيراد مقابل الطلبات',
      'statsTopProductsTitle': 'أفضل المنتجات',
      'statsMetricRevenue': 'الإيراد',
      'statsMetricOrders': 'الطلبات',
      'statsMetricConversion': 'معدل التحويل',
      'statsMetricAvgOrder': 'متوسط الطلب',
      'statsMetricCustomers': 'العملاء',
      'statsMetricReturnRate': 'معدل الإرجاع',
      'statsCategoryTitle': 'المبيعات حسب الفئة',
      'statsCategoryAction': 'عرض التفاصيل',
      'statsMonthlyTitle': 'الأداء الشهري',
      'statsMonthlyAction': 'عرض التقرير',
      'statsSoldCount': 'تم بيع {count}',
      'statsShopSnapshotTitle': 'لمحة المتجر',
      'statsShopSnapshotSubtitle': 'نظرة سريعة على إجماليات المتجر.',
      'statsShopSalesTitle': 'المبيعات والأرباح',
      'statsShopSalesSubtitle': 'إجماليات أداء المتجر.',
      'statsShopGrossSalesLabel': 'إجمالي المبيعات',
      'statsShopPaidSalesLabel': 'المبيعات المدفوعة',
      'statsShopEarningsApprovedLabel': 'أرباح معتمدة',
      'statsShopEarningsPendingLabel': 'أرباح معلقة',
      'statsShopEarningsRefundedLabel': 'أرباح مستردة',
      'statsShopProductsLabel': 'المنتجات',
      'statsShopOrdersLabel': 'الطلبات',
      'statsShopFollowersLabel': 'المتابعون',
      'statsShopAvgRatingLabel': 'متوسط التقييم',
      'statsLoadFailed': 'تعذر تحميل الإحصائيات.',
      'statsNoData': 'لا توجد بيانات بعد.',
      'productsSearchHint': 'ابحث باسم المنتج أو SKU',
      'productsCategoryAll': 'الكل',
      'productsCategoryClothes': 'ملابس',
      'productsCategoryShoes': 'أحذية',
      'productsCategoryBags': 'حقائب',
      'productsCategoryAccessories': 'إكسسوارات',
      'productsFilterAll': 'الكل',
      'productsFilterActive': 'نشط',
      'productsFilterInactive': 'غير نشط',
      'productsStockFilterAll': 'الكل',
      'productsStockFilterLow': 'مخزون منخفض',
      'productsStockFilterOut': 'نفاد المخزون',
      'productsSummaryTotal': 'إجمالي المنتجات',
      'productsSummaryActive': 'نشط',
      'productsSummaryLowStock': 'مخزون منخفض',
      'productsListTitle': 'المنتجات ({count})',
      'productsSortNewest': 'الترتيب: الأحدث',
      'productsStatusActive': 'نشط',
      'productsStatusInactive': 'غير نشط',
      'productsStatusDraft': 'مسودة',
      'productsStockOut': 'نفاد المخزون',
      'productsStockUnknown': 'المخزون • --',
      'productsStockLow': 'مخزون منخفض • {count}',
      'productsStockAvailable': 'المخزون • {count}',
      'productsQuickActions': 'إجراءات سريعة',
      'productsActionToggleStatus': 'تبديل الحالة',
      'productsActionUpdateDiscount': 'تحديث الخصم',
      'productsActionUpdatePrice': 'تحديث السعر',
      'productsActionUpdateStock': 'تحديث المخزون',
      'productsStatusUpdated': 'تم تحديث الحالة.',
      'productsStatusUpdateFailed': 'فشل تحديث الحالة.',
      'productsDiscountDialogTitle': 'تحديث الخصم',
      'productsDiscountTypeLabel': 'نوع الخصم',
      'productsDiscountTypeFixed': 'قيمة ثابتة',
      'productsDiscountTypePercent': 'نسبة مئوية',
      'productsDiscountAmountLabel': 'قيمة الخصم',
      'productsDiscountUpdated': 'تم تحديث الخصم.',
      'productsDiscountUpdateFailed': 'فشل تحديث الخصم.',
      'productsPriceDialogTitle': 'تحديث السعر',
      'productsPurchasePriceLabel': 'سعر الشراء',
      'productsUnitPriceLabel': 'سعر البيع',
      'productsPriceUpdated': 'تم تحديث السعر.',
      'productsPriceUpdateFailed': 'فشل تحديث السعر.',
      'productsStockDialogTitle': 'تحديث المخزون',
      'productsQuantityLabel': 'الكمية',
      'productsStockUpdated': 'تم تحديث المخزون.',
      'productsStockUpdateFailed': 'فشل تحديث المخزون.',
      'productsVariationPriceDialogTitle': 'تحديث أسعار المتغيرات',
      'productsVariationStockDialogTitle': 'تحديث مخزون المتغيرات',
      'productsVariationsEmpty': 'لا توجد متغيرات لهذا المنتج.',
      'productsVariationLabel': 'متغير {index}',
      'productsVariationCodeLabel': 'رمز المتغير',
      'productsAddVariation': 'إضافة متغير',
      'productsVariationsTitle': 'المتغيرات',
      'productsDiscountTitle': 'الخصم',
      'productsThumbnailTitle': 'صورة الغلاف',
      'productsThumbnailLabel': 'رفع صورة الغلاف',
      'productsPermalinkLabel': 'الرابط المختصر',
      'productsTypeLabel': 'نوع المنتج',
      'productsTypeSingle': 'مفرد',
      'productsTypeVariable': 'متغير',
      'productsConditionLabel': 'الحالة',
      'productsFormNameRequired': 'أدخل اسم المنتج.',
      'productsFormPermalinkRequired': 'أدخل الرابط المختصر.',
      'productsFormVariationRequired': 'أضف متغيرًا واحدًا على الأقل.',
      'productsSaveFailed': 'فشل حفظ المنتج.',
      'productsDeleteFailed': 'فشل حذف المنتج.',
      'productsImageTooLarge': 'يجب أن يكون حجم الصورة أقل من ٤ ميجابايت.',
      'productsImageUploadFailed': 'فشل رفع الصورة.',
      'productsLoadFailed': 'فشل تحميل المنتجات.',
      'productsEmptyMessage': 'لا توجد منتجات بعد.',
      'productsProductId': 'المعرف',
      'productsUnnamed': 'منتج بدون اسم',
      'addProductTitle': 'إضافة منتج',
      'addProductSaveDraft': 'حفظ المسودة',
      'addProductDraftSavedMessage': 'تم حفظ المسودة.',
      'addProductSubmittedMessage': 'تم إرسال المنتج للمراجعة.',
      'addProductStepIndicator': 'الخطوة {current} من {total}',
      'addProductStepBasics': 'الأساسيات',
      'addProductStepPricing': 'التسعير',
      'addProductStepMedia': 'الوسائط',
      'addProductCancel': 'إلغاء',
      'addProductBack': 'رجوع',
      'addProductNext': 'التالي',
      'addProductPublish': 'نشر',
      'addProductBasicsTitle': 'أساسيات المنتج',
      'addProductBasicsSubtitle': 'أضف التفاصيل الأساسية للمنتج ضمن الكتالوج.',
      'addProductNameLabel': 'اسم المنتج',
      'addProductSkuLabel': 'SKU',
      'addProductCategoryLabel': 'الفئة',
      'addProductCategoryPropertiesTitle': 'خصائص الفئة',
      'addProductCategoryPropertiesSubtitle': 'اختر السمات المناسبة لهذه الفئة.',
      'addProductDescriptionLabel': 'الوصف',
      'addProductTagsTitle': 'الوسوم',
      'addProductTagBestseller': 'الأكثر مبيعًا',
      'addProductTagNew': 'جديد',
      'addProductTagOrganic': 'عضوي',
      'addProductTagGiftable': 'مناسب للهدايا',
      'addProductTagLimited': 'إصدار محدود',
      'addProductPropertySize': 'المقاس',
      'addProductPropertyColor': 'اللون',
      'addProductPropertyMaterial': 'الخامة',
      'addProductPropertyFit': 'القَصّة',
      'addProductPropertyStyle': 'الطراز',
      'addProductPropertyStrap': 'الحزام',
      'addProductPricingTitle': 'التسعير والمخزون',
      'addProductPricingSubtitle': 'حدد السعر والتكلفة وتوافر المخزون.',
      'addProductPriceLabel': 'السعر',
      'addProductCompareLabel': 'سعر المقارنة',
      'addProductUnitLabel': 'الوحدة',
      'addProductUnitPiece': 'قطعة',
      'addProductUnitBottle': 'زجاجة',
      'addProductUnitBox': 'صندوق',
      'addProductUnitSet': 'طقم',
      'addProductTrackInventory': 'تتبع المخزون',
      'addProductStockQuantity': 'كمية المخزون',
      'addProductLowStockAlert': 'تنبيه انخفاض المخزون',
      'addProductAllowBackorders': 'السماح بالطلبات المؤجلة',
      'addProductFeatureProduct': 'تمييز هذا المنتج',
      'addProductMediaTitle': 'الوسائط والظهور',
      'addProductMediaSubtitle': 'ارفع الصور وحدد أماكن البيع.',
      'addProductImagesTitle': 'صور المنتج',
      'addProductImageCover': 'الغلاف',
      'addProductImageLabel': 'صورة {index}',
      'addProductImagePickerMessage': 'محدد الصور غير متصل بعد.',
      'addProductDeliveryTitle': 'خيارات التوصيل',
      'addProductDeliveryCourier': 'توصيل',
      'addProductDeliveryPickup': 'استلام',
      'addProductDeliverySameDay': 'في نفس اليوم',
      'addProductPublishToggle': 'نشر في السوق',
      'addProductPublishNote':
          'سيظهر المنتج في كتالوج البائع والسوق بعد الموافقة.',
      'addProductSizeMini': 'ميني',
      'addProductSizeSmall': 'صغير',
      'addProductSizeMedium': 'متوسط',
      'addProductSizeLarge': 'كبير',
      'addProductColorBlack': 'أسود',
      'addProductColorWhite': 'أبيض',
      'addProductColorBeige': 'بيج',
      'addProductColorBlue': 'أزرق',
      'addProductColorGreen': 'أخضر',
      'addProductColorRed': 'أحمر',
      'addProductColorBrown': 'بني',
      'addProductColorGray': 'رمادي',
      'addProductColorNavy': 'كحلي',
      'addProductColorOlive': 'زيتي',
      'addProductColorGold': 'ذهبي',
      'addProductColorSilver': 'فضي',
      'addProductColorRose': 'وردي',
      'addProductColorPearl': 'لؤلؤي',
      'addProductMaterialCotton': 'قطن',
      'addProductMaterialLinen': 'كتان',
      'addProductMaterialSilk': 'حرير',
      'addProductMaterialDenim': 'دينم',
      'addProductMaterialWool': 'صوف',
      'addProductMaterialLeather': 'جلد',
      'addProductMaterialSuede': 'شمواه',
      'addProductMaterialCanvas': 'كانفاس',
      'addProductMaterialSynthetic': 'صناعي',
      'addProductMaterialNylon': 'نايلون',
      'addProductMaterialMetal': 'معدن',
      'addProductMaterialFabric': 'قماش',
      'addProductMaterialResin': 'راتنج',
      'addProductFitSlim': 'ضيّق',
      'addProductFitRegular': 'قياسي',
      'addProductFitRelaxed': 'مريح',
      'addProductFitOversized': 'واسع',
      'addProductStyleSneaker': 'سنيكرز',
      'addProductStyleLoafer': 'لوفر',
      'addProductStyleBoot': 'بوت',
      'addProductStyleHeel': 'كعب',
      'addProductStyleSandal': 'صندل',
      'addProductStyleMinimal': 'بسيط',
      'addProductStyleStatement': 'جريء',
      'addProductStyleClassic': 'كلاسيكي',
      'addProductStyleModern': 'عصري',
      'addProductStrapShort': 'قصير',
      'addProductStrapLong': 'طويل',
      'addProductStrapAdjustable': 'قابل للتعديل',
      'editProductTitle': 'تعديل المنتج',
      'editProductSaveAction': 'حفظ التغييرات',
      'editProductDeleteAction': 'حذف',
      'editProductDeleteTitle': 'حذف المنتج؟',
      'editProductDeleteMessage': 'لا يمكن التراجع عن هذا الإجراء.',
      'editProductDeleteCancel': 'إلغاء',
      'editProductDeleteConfirm': 'حذف',
      'editProductUpdatedMessage': 'تم تحديث المنتج.',
      'editProductDeletedMessage': 'تم حذف المنتج.',
      'drawerStoreProfileTitle': 'ملف المتجر',
      'drawerStoreProfileSubtitle': 'إدارة تفاصيل المتجر',
      'drawerSettingsTitle': 'الإعدادات',
      'drawerSettingsSubtitle': 'التفضيلات والأمان',
      'drawerSupportTitle': 'الدعم',
      'drawerSupportSubtitle': 'الحصول على المساعدة والملاحظات',
      'drawerActive': 'نشط',
      'drawerLogOut': 'تسجيل الخروج',
      'drawerLogOutTitle': 'تسجيل الخروج',
      'drawerLogOutMessage':
          'هل أنت متأكد أنك تريد تسجيل الخروج من Majdoleen Seller؟',
      'drawerCancel': 'إلغاء',
      'drawerComingSoon': 'سيتم توفير {label} قريبًا.',
      'storeProfileTitle': 'ملف المتجر',
      'storeProfileSubtitle': 'حدّث طريقة ظهور متجرك للعملاء.',
      'storeProfileLogoTitle': 'شعار المتجر',
      'storeProfileLogoHint': 'يوصى بـ 512x512 PNG',
      'storeProfileLogoUpdateAction': 'تحديث الشعار',
      'storeProfileBannerLabel': 'غلاف المتجر',
      'storeProfileBannerUpdateAction': 'تحديث الغلاف',
      'storeProfileDetailsTitle': 'تفاصيل المتجر',
      'storeProfileNameLabel': 'اسم المتجر',
      'storeProfileNameHint': 'أدخل اسم المتجر',
      'storeProfileSlugLabel': 'رابط المتجر',
      'storeProfileSlugHint': 'متجرك-هنا',
      'storeProfileTaglineLabel': 'العبارة التعريفية',
      'storeProfileDescriptionLabel': 'الوصف',
      'storeProfileCategoryLabel': 'الفئة',
      'storeProfileContactTitle': 'التواصل والموقع',
      'storeProfileSellerPhoneLabel': 'هاتف البائع',
      'storeProfileSellerPhoneHint': 'أدخل هاتف البائع',
      'storeProfileShopPhoneLabel': 'هاتف المتجر',
      'storeProfileShopPhoneHint': 'أدخل هاتف المتجر',
      'storeProfilePhoneLabel': 'الهاتف',
      'storeProfileEmailLabel': 'البريد الإلكتروني',
      'storeProfileAddressLabel': 'العنوان',
      'storeProfileAddressHint': 'أدخل عنوان المتجر',
      'storeProfileSeoTitle': 'إعدادات تحسين الظهور',
      'storeProfileMetaTitleLabel': 'عنوان الميتا',
      'storeProfileMetaTitleHint': 'أدخل عنوان الميتا',
      'storeProfileMetaDescriptionLabel': 'وصف الميتا',
      'storeProfileMetaDescriptionHint': 'أدخل وصف الميتا',
      'storeProfileMetaImageLabel': 'صورة الميتا',
      'storeProfileMetaImageUpdateAction': 'تحديث الصورة',
      'storeProfileStatusTitle': 'حالة المتجر',
      'storeProfileStatusOpenTitle': 'تفعيل المتجر',
      'storeProfileStatusOpenSubtitle': 'إظهار المتجر كمتاح للعملاء',
      'storeProfileStatusAcceptingTitle': 'استقبال الطلبات',
      'storeProfileStatusAcceptingSubtitle': 'السماح بتلقي طلبات جديدة',
      'storeProfileStatusVacationTitle': 'وضع الإجازة',
      'storeProfileStatusVacationSubtitle': 'إيقاف الطلبات لفترة محددة',
      'storeProfileStatusVacationNotice':
          'وضع الإجازة مفعل. لا يمكن للعملاء تقديم طلبات جديدة.',
      'storeProfileFulfillmentTitle': 'تنفيذ الطلبات',
      'storeProfilePickupTitle': 'استلام',
      'storeProfilePickupSubtitle': 'السماح للعملاء باستلام الطلبات',
      'storeProfileDeliveryTitle': 'توصيل',
      'storeProfileDeliverySubtitle': 'تقديم خدمة التوصيل للمتجر',
      'storeProfilePrepTimeLabel': 'وقت تجهيز الطلب',
      'storeProfileBusinessHoursTitle': 'ساعات العمل',
      'storeProfilePreviewAction': 'معاينة',
      'storeProfileSaveAction': 'حفظ التغييرات',
      'storeProfileSavedMessage': 'تم حفظ ملف المتجر.',
      'storeProfilePreviewMessage': 'المعاينة متاحة قريبًا.',
      'storeProfileImageUpdatedMessage': 'تم تحديث صورة المتجر.',
      'storeProfileImageUpdateFailed': 'تعذر تحديث صورة المتجر.',
      'storeProfileImagePickFailed': 'تعذر اختيار الصورة.',
      'storeProfileImageTooLarge': 'يجب ألا يتجاوز حجم الصورة 4 ميجابايت.',
      'storeProfileAuthRequired': 'يرجى تسجيل الدخول لإدارة المتجر.',
      'storeProfileLoadFailed': 'تعذر تحميل تفاصيل المتجر.',
      'storeProfileUpdateFailed': 'تعذر تحديث المتجر.',
      'storeProfileNameRequired': 'يرجى إدخال اسم المتجر.',
      'storeProfileShopPhoneRequired': 'يرجى إدخال هاتف المتجر.',
      'storeProfileSlugRequired': 'يرجى إدخال رابط المتجر.',
      'storeProfileCategorySkincare': 'العناية بالبشرة',
      'storeProfileCategoryFragrance': 'العطور',
      'storeProfileCategoryBeauty': 'الجمال',
      'storeProfileCategoryAccessories': 'الإكسسوارات',
      'storeProfilePrepSameDay': 'نفس اليوم',
      'storeProfilePrep1to2Days': '1-2 يوم',
      'storeProfilePrep3to5Days': '3-5 أيام',
      'storeProfileDayMon': 'اثن',
      'storeProfileDayTue': 'ثلا',
      'storeProfileDayWed': 'أرب',
      'storeProfileDayThu': 'خمي',
      'storeProfileDayFri': 'جمع',
      'storeProfileDaySat': 'سبت',
      'storeProfileDaySun': 'أحد',
      'storeProfileHoursRegular': '9:00 ص - 9:00 م',
      'storeProfileHoursLate': '9:00 ص - 10:00 م',
      'storeProfileHoursFriday': '2:00 م - 11:00 م',
      'storeProfileHoursWeekend': '10:00 ص - 10:00 م',
      'storeProfileHoursClosed': 'مغلق',
      'settingsTitle': 'الإعدادات',
      'settingsSubtitle': 'إدارة التنبيهات والتفضيلات والأمان.',
      'settingsNotificationsTitle': 'الإشعارات',
      'settingsOrderUpdatesTitle': 'تحديثات الطلبات',
      'settingsOrderUpdatesSubtitle': 'طلبات جديدة وإلغاءات واستردادات',
      'settingsPayoutUpdatesTitle': 'تحديثات المدفوعات',
      'settingsPayoutUpdatesSubtitle':
          'التحويلات والتعليق والمدفوعات الفاشلة',
      'settingsLowStockAlertsTitle': 'تنبيهات انخفاض المخزون',
      'settingsLowStockAlertsSubtitle': 'تذكيرات عند انخفاض المخزون',
      'settingsMarketingUpdatesTitle': 'تحديثات التسويق',
      'settingsMarketingUpdatesSubtitle': 'نصائح المنتجات والحملات الموسمية',
      'settingsSecurityTitle': 'الأمان',
      'settingsTwoFactorTitle': 'المصادقة الثنائية',
      'settingsTwoFactorSubtitle': 'يتطلب رمزًا لمرة واحدة عند تسجيل الدخول',
      'settingsBiometricTitle': 'تسجيل الدخول بالبصمة',
      'settingsBiometricSubtitle': 'استخدم البصمة للوصول إلى التطبيق',
      'settingsChangePasswordTitle': 'تغيير كلمة المرور',
      'settingsChangePasswordSubtitle': 'حدّث كلمة المرور بانتظام',
      'settingsPasswordComingSoonMessage': 'تحديث كلمة المرور متاح قريبًا.',
      'settingsPreferencesTitle': 'التفضيلات',
      'settingsLanguageLabel': 'اللغة',
      'settingsCurrencyLabel': 'العملة',
      'settingsTimeZoneLabel': 'المنطقة الزمنية',
      'settingsLanguageEnglish': 'الإنجليزية',
      'settingsLanguageArabic': 'العربية',
      'settingsAccountTitle': 'الحساب',
      'settingsTeamMembersTitle': 'أعضاء الفريق',
      'settingsTeamMembersSubtitle': 'دعوة وإدارة حسابات الموظفين',
      'settingsTeamComingSoonMessage': 'إعدادات الفريق متاحة قريبًا.',
      'settingsBillingTitle': 'الفواتير',
      'settingsBillingSubtitle': 'الفواتير وبيانات التحويل',
      'settingsBillingComingSoonMessage': 'الفواتير متاحة قريبًا.',
      'settingsHelpCenterTitle': 'مركز المساعدة',
      'settingsHelpCenterSubtitle': 'الحصول على المساعدة ومواد الدعم',
      'settingsHelpCenterComingSoonMessage': 'مركز المساعدة متاح قريبًا.',
      'settingsPlansTitle': 'خطط الاشتراك',
      'settingsPlansSubtitle': 'قارن الباقات وطوّر متجرك',
      'subscriptionPlansTitle': 'خطط الاشتراك',
      'subscriptionPlansSubtitle': 'اختر الخطة المناسبة لحجم متجرك.',
      'subscriptionPlansSectionTitle': 'خيارات الخطط',
      'subscriptionCurrentLabel': 'الخطة الحالية',
      'subscriptionRecommendedBadge': 'الأفضل قيمة',
      'subscriptionFreeName': 'مجانية',
      'subscriptionPlusName': 'بلس',
      'subscriptionProName': 'برو',
      'subscriptionFreeDescription': 'للبائعين في البداية',
      'subscriptionPlusDescription': 'للكتالوجات المتنامية',
      'subscriptionProDescription': 'للفِرق ذات الحجم الكبير',
      'subscriptionFreePrice': 'مجانية',
      'subscriptionPlusPrice': '79 ر.س',
      'subscriptionProPrice': '199 ر.س',
      'subscriptionPerMonth': 'شهريًا',
      'subscriptionForever': 'مدى الحياة',
      'subscriptionProductsLimit': 'حتى {count} منتج',
      'subscriptionItemsLimit': 'حتى {count} عنصر',
      'subscriptionProductsUnlimited': 'منتجات غير محدودة',
      'subscriptionItemsUnlimited': 'عناصر غير محدودة',
      'subscriptionBasicAnalytics': 'تحليلات أساسية',
      'subscriptionAdvancedAnalytics': 'تحليلات متقدمة',
      'subscriptionCustomInsights': 'رؤى مخصصة',
      'subscriptionEmailSupport': 'دعم عبر البريد',
      'subscriptionPrioritySupport': 'دعم أولوية',
      'subscriptionDedicatedSuccess': 'مدير نجاح مخصص',
      'subscriptionChooseAction': 'اختيار الخطة',
      'subscriptionCurrentAction': 'الخطة الحالية',
      'subscriptionChangeMessage': 'تغيير الخطة متاح قريبًا.',
      'subscriptionCurrentSummary': 'أنت على خطة {plan}.',
      'subscriptionCurrentHint': 'يمكنك الترقية في أي وقت لزيادة الحدود.',
      'subscriptionFooterNote': 'تجدد الخطط تلقائيًا. يمكنك الإلغاء في أي وقت.',
      'subscriptionConfirmTitle': 'هل تريد التبديل إلى خطة {plan}؟',
      'subscriptionConfirmSubtitle': 'تُطبق الحدود الجديدة فورًا.',
      'subscriptionConfirmAction': 'تأكيد الخطة',
      'subscriptionUpdatedMessage': 'تم تحديث الخطة إلى {plan}.',
      'ordersSearchHint': 'ابحث برقم الطلب أو العميل',
      'ordersFilterTitle': 'تصفية الطلبات',
      'ordersFilterPaymentTitle': 'الدفع',
      'ordersFilterDeliveryTitle': 'التوصيل',
      'ordersFilterPayoutTitle': 'حالة التحويل',
      'ordersFilterLocationTitle': 'الموقع',
      'ordersFilterPriorityOnly': 'الطلبات ذات الأولوية فقط',
      'ordersFilterClearAction': 'مسح',
      'ordersFilterApplyAction': 'تطبيق',
      'ordersFilterAll': 'الكل',
      'ordersEmptyFiltered': 'لا توجد طلبات تطابق عوامل التصفية الحالية.',
      'ordersEmpty': 'لا توجد طلبات بعد.',
      'ordersLoadFailed': 'تعذر تحميل الطلبات.',
      'ordersCountersFailed': 'تعذر تحميل أعداد الطلبات.',
      'ordersListTitle': 'الطلبات ({count})',
      'ordersSortLatest': 'الترتيب: الأحدث',
      'ordersPriorityBadge': 'أولوية',
      'ordersStatusNew': 'جديد',
      'ordersStatusPending': 'معلّق',
      'ordersStatusProcessing': 'قيد المعالجة',
      'ordersStatusReady': 'جاهز',
      'ordersStatusReadyToShip': 'جاهز للشحن',
      'ordersStatusShipped': 'تم الشحن',
      'ordersStatusDelivered': 'تم التسليم',
      'ordersStatusCancelled': 'ملغي',
      'ordersPaymentCard': 'بطاقة',
      'ordersPaymentCash': 'نقدًا',
      'ordersPaymentWallet': 'محفظة',
      'ordersPaymentStatusPaid': 'مدفوع',
      'ordersPaymentStatusUnpaid': 'غير مدفوع',
      'ordersPaymentStatusRefunded': 'مسترد',
      'ordersPaymentCashOnDelivery': 'الدفع عند الاستلام',
      'ordersPaymentCombined': '{method} • {status}',
      'ordersDeliveryCourier': 'شركة الشحن',
      'ordersDeliveryPickup': 'استلام',
      'ordersPayoutPending': 'تحويل قيد الانتظار',
      'ordersPayoutHold': 'تحويل معلّق',
      'ordersPayoutScheduled': 'مجدول',
      'ordersPayoutPaid': 'تم التحويل',
      'ordersPayoutRefunded': 'مسترد',
      'ordersLocationRiyadh': 'الرياض',
      'ordersLocationDiriyah': 'الدرعية',
      'ordersItemsLine': '{count} عناصر • {total}',
      'ordersItemsCount': '{count} عناصر',
      'ordersTimeMinutesAgo': 'قبل {count} دقيقة',
      'ordersTimeHoursAgo': 'قبل {count} ساعة',
      'ordersUnknownCustomer': 'عميل غير معروف',
      'ordersDetailsTitle': 'تفاصيل الطلب',
      'ordersDetailsLoadFailed': 'تعذر تحميل تفاصيل الطلب.',
      'ordersDetailsSummaryTitle': 'ملخص الطلب',
      'ordersDetailsCustomerLabel': 'العميل',
      'ordersDetailsItemsLabel': 'العناصر',
      'ordersDetailsItemsTitle': 'عناصر الطلب',
      'ordersDetailsItemQuantity': 'الكمية: {count}',
      'ordersDetailsItemUnitPrice': 'سعر الوحدة: {price}',
      'ordersDetailsOptionSize': 'الحجم',
      'ordersDetailsOptionColor': 'اللون',
      'ordersDetailsTotalLabel': 'الإجمالي',
      'ordersDetailsPaymentLabel': 'الدفع',
      'ordersDetailsDeliveryLabel': 'التوصيل',
      'ordersDetailsPayoutLabel': 'التحويل',
      'ordersDetailsLocationLabel': 'الموقع',
      'ordersDetailsPlacedLabel': 'وقت الطلب',
      'ordersDetailsStatusTitle': 'تحديث الحالة',
      'ordersDetailsPriorityToggle': 'تحديد كأولوية',
      'ordersDetailsAssignmentTitle': 'تعيين جهة التوصيل',
      'ordersDetailsDeliveryCompanyLabel': 'شركة التوصيل',
      'ordersDetailsAssignmentHint': 'اختر جهة التوصيل المناسبة',
      'ordersDetailsAssignmentUnassigned': 'غير معيّن',
      'ordersDetailsAssignmentPickupNote':
          'طلبات الاستلام لا تحتاج إلى جهة توصيل.',
      'ordersDetailsNotesTitle': 'ملاحظات داخلية',
      'ordersDetailsNotesHint': 'أضف ملاحظات لفريقك',
      'ordersDetailsSaveAction': 'حفظ التغييرات',
      'ordersDetailsSavedMessage': 'تم تحديث الطلب.',
      'ordersDetailsRejectAction': 'إلغاء الطلب',
      'ordersDetailsRejectTitle': 'إلغاء هذا الطلب؟',
      'ordersDetailsRejectMessage': 'سيتم إلغاء الطلب للعميل.',
      'ordersDetailsRejectCancel': 'إبقاء الطلب',
      'ordersDetailsRejectConfirm': 'إلغاء الطلب',
      'ordersDetailsRejectedMessage': 'تم إلغاء الطلب.',
      'ordersStatusUpdateFailed': 'تعذر تحديث حالة الطلب.',
      'ordersAcceptAction': 'قبول الطلب',
      'ordersAcceptSuccess': 'تم قبول الطلب.',
      'ordersAcceptFailed': 'تعذر قبول الطلب.',
      'ordersCancelSuccess': 'تم إلغاء الطلب.',
      'ordersCancelFailed': 'تعذر إلغاء الطلب.',
      'ordersStatusInvalidDeliveredUnpaid':
          'لا يمكن تعيين الطلب كمُسلّم والدفع غير مدفوع.',
      'ordersDetailsDeliveryPartnerFalcon': 'فالكون لوجستكس',
      'ordersDetailsDeliveryPartnerSwift': 'سويفت إكسبريس',
      'ordersDetailsDeliveryPartnerDesertGo': 'ديزرت جو',
    },
  };

  String _value(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  String get loginTitle => _value('loginTitle');
  String get loginHeadline => _value('loginHeadline');
  String get loginSubtitle => _value('loginSubtitle');
  String get emailLabel => _value('emailLabel');
  String get emailHint => _value('emailHint');
  String get addressLabel => _value('addressLabel');
  String get addressHint => _value('addressHint');
  String get phoneLabel => _value('phoneLabel');
  String get phoneHint => _value('phoneHint');
  String get passwordLabel => _value('passwordLabel');
  String get passwordHint => _value('passwordHint');
  String get loginAction => _value('loginAction');
  String get loginMissingFields => _value('loginMissingFields');
  String get loginFailed => _value('loginFailed');
  String get rememberMe => _value('rememberMe');
  String get forgotPassword => _value('forgotPassword');
  String get forgotPasswordTitle => _value('forgotPasswordTitle');
  String get forgotPasswordSubtitle => _value('forgotPasswordSubtitle');
  String get forgotPasswordPhoneRequired => _value('forgotPasswordPhoneRequired');
  String get forgotPasswordAction => _value('forgotPasswordAction');
  String get forgotPasswordHelper => _value('forgotPasswordHelper');
  String get forgotPasswordRememberPrompt =>
      _value('forgotPasswordRememberPrompt');
  String get forgotPasswordBackToLogin => _value('forgotPasswordBackToLogin');
  String get forgotPasswordOtpSent => _value('forgotPasswordOtpSent');
  String get forgotPasswordOtpResent => _value('forgotPasswordOtpResent');
  String get forgotPasswordFailed => _value('forgotPasswordFailed');
  String get forgotPasswordVerifyTitle => _value('forgotPasswordVerifyTitle');
  String forgotPasswordVerifySubtitle(String phone) {
    final template = _value('forgotPasswordVerifySubtitle');
    return template.replaceAll('{phone}', phone);
  }
  String get forgotPasswordVerifyAction => _value('forgotPasswordVerifyAction');
  String get forgotPasswordVerifyHelper => _value('forgotPasswordVerifyHelper');
  String get forgotPasswordVerifyNoCodePrompt =>
      _value('forgotPasswordVerifyNoCodePrompt');
  String get forgotPasswordResendAction => _value('forgotPasswordResendAction');
  String forgotPasswordResendIn(String seconds) {
    final template = _value('forgotPasswordResendIn');
    return template.replaceAll('{seconds}', seconds);
  }
  String get forgotPasswordOtpRequired => _value('forgotPasswordOtpRequired');
  String get forgotPasswordOtpInvalid => _value('forgotPasswordOtpInvalid');
  String get forgotPasswordOtpExpired => _value('forgotPasswordOtpExpired');
  String get forgotPasswordOtpVerified => _value('forgotPasswordOtpVerified');
  String get forgotPasswordOtpVerificationFailed =>
      _value('forgotPasswordOtpVerificationFailed');
  String get resetPasswordTitle => _value('resetPasswordTitle');
  String get resetPasswordSubtitle => _value('resetPasswordSubtitle');
  String get resetPasswordLabel => _value('resetPasswordLabel');
  String get resetPasswordHint => _value('resetPasswordHint');
  String get resetPasswordConfirmLabel => _value('resetPasswordConfirmLabel');
  String get resetPasswordConfirmHint => _value('resetPasswordConfirmHint');
  String get resetPasswordAction => _value('resetPasswordAction');
  String get resetPasswordHelper => _value('resetPasswordHelper');
  String get resetPasswordRequired => _value('resetPasswordRequired');
  String get resetPasswordMinLength => _value('resetPasswordMinLength');
  String get resetPasswordConfirmRequired =>
      _value('resetPasswordConfirmRequired');
  String get resetPasswordMismatch => _value('resetPasswordMismatch');
  String get resetPasswordSuccess => _value('resetPasswordSuccess');
  String get resetPasswordFailed => _value('resetPasswordFailed');
  String get resetPasswordInvalidToken => _value('resetPasswordInvalidToken');
  String get resetPasswordExpiredToken => _value('resetPasswordExpiredToken');
  String get resetPasswordTokenError => _value('resetPasswordTokenError');
  String get resetPasswordBackPrompt => _value('resetPasswordBackPrompt');
  String get resetPasswordBackToLogin => _value('resetPasswordBackToLogin');
  String get noAccountPrompt => _value('noAccountPrompt');
  String get registerAction => _value('registerAction');
  String get registerTitle => _value('registerTitle');
  String get registerHeadline => _value('registerHeadline');
  String get registerSubtitle => _value('registerSubtitle');
  String get fullNameLabel => _value('fullNameLabel');
  String get confirmPasswordLabel => _value('confirmPasswordLabel');
  String get registerSendOtpAction => _value('registerSendOtpAction');
  String get registerCountryCodeShort => _value('registerCountryCodeShort');
  String get registerCountryCodeRequired => _value('registerCountryCodeRequired');
  String get registerTermsPrefix => _value('registerTermsPrefix');
  String get registerTermsLink => _value('registerTermsLink');
  String get registerTermsSuffix => _value('registerTermsSuffix');
  String get registerTermsRequired => _value('registerTermsRequired');
  String get registerSendOtpFailed => _value('registerSendOtpFailed');
  String get registerVerificationTokenMissing =>
      _value('registerVerificationTokenMissing');
  String get registerCompleteFailed => _value('registerCompleteFailed');
  String get registerNameRequired => _value('registerNameRequired');
  String get registerEmailInvalid => _value('registerEmailInvalid');
  String get registerShopNameLabel => _value('registerShopNameLabel');
  String get registerShopNameHint => _value('registerShopNameHint');
  String get registerShopNameRequired => _value('registerShopNameRequired');
  String get registerShopPhoneLabel => _value('registerShopPhoneLabel');
  String get registerShopPhoneHint => _value('registerShopPhoneHint');
  String get registerShopUrlLabel => _value('registerShopUrlLabel');
  String get registerShopUrlHint => _value('registerShopUrlHint');
  String get registerPasswordRequired => _value('registerPasswordRequired');
  String get registerPasswordMinLength => _value('registerPasswordMinLength');
  String get registerConfirmPasswordRequired =>
      _value('registerConfirmPasswordRequired');
  String get registerPasswordMismatch => _value('registerPasswordMismatch');
  String get registerGenderLabel => _value('registerGenderLabel');
  String get registerGenderHint => _value('registerGenderHint');
  String get registerGenderMale => _value('registerGenderMale');
  String get registerGenderFemale => _value('registerGenderFemale');
  String get registerGenderOther => _value('registerGenderOther');
  String get registerGenderRequired => _value('registerGenderRequired');
  String get registerCityLabel => _value('registerCityLabel');
  String get registerCityHint => _value('registerCityHint');
  String get registerCityRequired => _value('registerCityRequired');
  String get registerCityLoading => _value('registerCityLoading');
  String get registerCityEmpty => _value('registerCityEmpty');
  String get registerCityLoadFailed => _value('registerCityLoadFailed');
  String get registerBirthdateLabel => _value('registerBirthdateLabel');
  String get registerBirthdateHint => _value('registerBirthdateHint');
  String get registerBirthdateRequired => _value('registerBirthdateRequired');
  String get registerBirthdateFormatError =>
      _value('registerBirthdateFormatError');
  String get registerBirthdateFutureError =>
      _value('registerBirthdateFutureError');
  String get registerBirthdatePickerTitle =>
      _value('registerBirthdatePickerTitle');
  String get registerBackAction => _value('registerBackAction');
  String get registerTermsOpenFailed => _value('registerTermsOpenFailed');
  String get createAccountAction => _value('createAccountAction');
  String get alreadyHaveAccountPrompt => _value('alreadyHaveAccountPrompt');
  String get loginLink => _value('loginLink');
  String get verificationTitle => _value('verificationTitle');
  String get verificationSubtitle => _value('verificationSubtitle');
  String get verificationSentToEmail => _value('verificationSentToEmail');
  String get verificationSentToPhone => _value('verificationSentToPhone');
  String get verificationCodeLabel => _value('verificationCodeLabel');
  String get verificationCodeHint => _value('verificationCodeHint');
  String get verificationMethodLabel => _value('verificationMethodLabel');
  String get verificationMethodEmail => _value('verificationMethodEmail');
  String get verificationMethodSms => _value('verificationMethodSms');
  String get verificationResendPrompt => _value('verificationResendPrompt');
  String get verificationResendAction => _value('verificationResendAction');
  String get verificationResendIn => _value('verificationResendIn');
  String get verificationVerifyAction => _value('verificationVerifyAction');
  String get verificationBackToLogin => _value('verificationBackToLogin');
  String get verificationCodeRequired => _value('verificationCodeRequired');
  String get verificationResentMessage => _value('verificationResentMessage');
  String get verificationCompleteMessage =>
      _value('verificationCompleteMessage');
  String get verificationInvalidCode => _value('verificationInvalidCode');
  String get verificationCodeExpired => _value('verificationCodeExpired');
  String get verificationTooManyRequests => _value('verificationTooManyRequests');
  String get verificationInvalidPhone => _value('verificationInvalidPhone');
  String get verificationSmsRegionBlocked => _value('verificationSmsRegionBlocked');
  String get verificationProviderDisabled => _value('verificationProviderDisabled');
  String get verificationNetworkError => _value('verificationNetworkError');
  String get verificationResendFailed => _value('verificationResendFailed');
  String get verificationBackendInvalidToken =>
      _value('verificationBackendInvalidToken');
  String get verificationBackendMissingPhone =>
      _value('verificationBackendMissingPhone');
  String get verificationBackendMisconfigured =>
      _value('verificationBackendMisconfigured');
  String get verificationUnexpectedError => _value('verificationUnexpectedError');
  String get approvalPendingTitle => _value('approvalPendingTitle');
  String get approvalPendingSubtitle => _value('approvalPendingSubtitle');
  String get approvalPendingAction => _value('approvalPendingAction');
  String get welcomeAppName => _value('welcomeAppName');
  String get welcomeSellerAppBadge => _value('welcomeSellerAppBadge');
  String get welcomeNext => _value('welcomeNext');
  String get welcomeGetStarted => _value('welcomeGetStarted');
  String get welcomeSkip => _value('welcomeSkip');
  String get welcomeSellerKit => _value('welcomeSellerKit');
  String get welcomeStep1Title => _value('welcomeStep1Title');
  String get welcomeStep1Subtitle => _value('welcomeStep1Subtitle');
  String get welcomeStep1Highlight1 => _value('welcomeStep1Highlight1');
  String get welcomeStep1Highlight2 => _value('welcomeStep1Highlight2');
  String get welcomeStep1Highlight3 => _value('welcomeStep1Highlight3');
  String get welcomeStep2Title => _value('welcomeStep2Title');
  String get welcomeStep2Subtitle => _value('welcomeStep2Subtitle');
  String get welcomeStep2Highlight1 => _value('welcomeStep2Highlight1');
  String get welcomeStep2Highlight2 => _value('welcomeStep2Highlight2');
  String get welcomeStep2Highlight3 => _value('welcomeStep2Highlight3');
  String get welcomeStep3Title => _value('welcomeStep3Title');
  String get welcomeStep3Subtitle => _value('welcomeStep3Subtitle');
  String get welcomeStep3Highlight1 => _value('welcomeStep3Highlight1');
  String get welcomeStep3Highlight2 => _value('welcomeStep3Highlight2');
  String get welcomeStep3Highlight3 => _value('welcomeStep3Highlight3');
  String get homeTodaySalesTitle => _value('homeTodaySalesTitle');
  String get homeTodaySalesSubtitle => _value('homeTodaySalesSubtitle');
  String get homePendingOrdersTitle => _value('homePendingOrdersTitle');
  String get homePendingOrdersSubtitle => _value('homePendingOrdersSubtitle');
  String get homeAvailableBalanceTitle => _value('homeAvailableBalanceTitle');
  String get homeAvailableBalanceSubtitle => _value('homeAvailableBalanceSubtitle');
  String get homeStoreRatingTitle => _value('homeStoreRatingTitle');
  String get homeStoreRatingSubtitle => _value('homeStoreRatingSubtitle');
  String get homeTodayOverviewTitle => _value('homeTodayOverviewTitle');
  String get homeQuickActionsTitle => _value('homeQuickActionsTitle');
  String get homeQuickActionsAction => _value('homeQuickActionsAction');
  String get homeNewOrdersTitle => _value('homeNewOrdersTitle');
  String get homeViewAllAction => _value('homeViewAllAction');
  String get homeInventoryAlertsTitle => _value('homeInventoryAlertsTitle');
  String get homeRestockAction => _value('homeRestockAction');
  String get homeQuickActionAddProduct => _value('homeQuickActionAddProduct');
  String get homeQuickActionCreateOffer => _value('homeQuickActionCreateOffer');
  String get homeQuickActionMessageBuyers => _value('homeQuickActionMessageBuyers');
  String get homeQuickActionRequestPayout => _value('homeQuickActionRequestPayout');
  String get homeOrderStatusPackaging => _value('homeOrderStatusPackaging');
  String get homeOrderStatusReadyForPickup => _value('homeOrderStatusReadyForPickup');
  String get homeOrderStatusNewOrder => _value('homeOrderStatusNewOrder');
  String get homeOrderTime12MinAgo => _value('homeOrderTime12MinAgo');
  String get homeOrderTime28MinAgo => _value('homeOrderTime28MinAgo');
  String get homeOrderTime1HrAgo => _value('homeOrderTime1HrAgo');
  String get homeInventoryOnly6Left => _value('homeInventoryOnly6Left');
  String get homeInventoryLowStock12Left => _value('homeInventoryLowStock12Left');
  String get homeInventoryRestockSoon => _value('homeInventoryRestockSoon');
  String get homeBalanceChangeThisWeek => _value('homeBalanceChangeThisWeek');
  String get homeNextPayoutLabel => _value('homeNextPayoutLabel');
  String get homeNextPayoutValue => _value('homeNextPayoutValue');
  String get homeOrdersTodayLabel => _value('homeOrdersTodayLabel');
  String get homeOrdersTodayValue => _value('homeOrdersTodayValue');
  String get navOrders => _value('navOrders');
  String get navHome => _value('navHome');
  String get navProducts => _value('navProducts');
  String get navPayouts => _value('navPayouts');
  String get navStats => _value('navStats');
  String get statsTitle => _value('statsTitle');
  String get statsSubtitle => _value('statsSubtitle');
  String get statsRangeWeek => _value('statsRangeWeek');
  String get statsRangeMonth => _value('statsRangeMonth');
  String get statsRangeQuarter => _value('statsRangeQuarter');
  String get statsRangeYear => _value('statsRangeYear');
  String get statsOverviewTitle => _value('statsOverviewTitle');
  String get statsOverviewSubtitle => _value('statsOverviewSubtitle');
  String get statsTrendTitle => _value('statsTrendTitle');
  String get statsTrendSubtitle => _value('statsTrendSubtitle');
  String get statsTopProductsTitle => _value('statsTopProductsTitle');
  String get statsMetricRevenue => _value('statsMetricRevenue');
  String get statsMetricOrders => _value('statsMetricOrders');
  String get statsMetricConversion => _value('statsMetricConversion');
  String get statsMetricAvgOrder => _value('statsMetricAvgOrder');
  String get statsMetricCustomers => _value('statsMetricCustomers');
  String get statsMetricReturnRate => _value('statsMetricReturnRate');
  String get statsCategoryTitle => _value('statsCategoryTitle');
  String get statsCategoryAction => _value('statsCategoryAction');
  String get statsMonthlyTitle => _value('statsMonthlyTitle');
  String get statsMonthlyAction => _value('statsMonthlyAction');
  String get statsShopSnapshotTitle => _value('statsShopSnapshotTitle');
  String get statsShopSnapshotSubtitle => _value('statsShopSnapshotSubtitle');
  String get statsShopSalesTitle => _value('statsShopSalesTitle');
  String get statsShopSalesSubtitle => _value('statsShopSalesSubtitle');
  String get statsShopGrossSalesLabel => _value('statsShopGrossSalesLabel');
  String get statsShopPaidSalesLabel => _value('statsShopPaidSalesLabel');
  String get statsShopEarningsApprovedLabel =>
      _value('statsShopEarningsApprovedLabel');
  String get statsShopEarningsPendingLabel =>
      _value('statsShopEarningsPendingLabel');
  String get statsShopEarningsRefundedLabel =>
      _value('statsShopEarningsRefundedLabel');
  String get statsShopProductsLabel => _value('statsShopProductsLabel');
  String get statsShopOrdersLabel => _value('statsShopOrdersLabel');
  String get statsShopFollowersLabel => _value('statsShopFollowersLabel');
  String get statsShopAvgRatingLabel => _value('statsShopAvgRatingLabel');
  String get statsLoadFailed => _value('statsLoadFailed');
  String get statsNoData => _value('statsNoData');
  String get productsSearchHint => _value('productsSearchHint');
  String get productsCategoryAll => _value('productsCategoryAll');
  String get productsCategoryClothes => _value('productsCategoryClothes');
  String get productsCategoryShoes => _value('productsCategoryShoes');
  String get productsCategoryBags => _value('productsCategoryBags');
  String get productsCategoryAccessories => _value('productsCategoryAccessories');
  String get productsFilterAll => _value('productsFilterAll');
  String get productsFilterActive => _value('productsFilterActive');
  String get productsFilterInactive => _value('productsFilterInactive');
  String get productsStockFilterAll => _value('productsStockFilterAll');
  String get productsStockFilterLow => _value('productsStockFilterLow');
  String get productsStockFilterOut => _value('productsStockFilterOut');
  String get productsSummaryTotal => _value('productsSummaryTotal');
  String get productsSummaryActive => _value('productsSummaryActive');
  String get productsSummaryLowStock => _value('productsSummaryLowStock');
  String get productsSortNewest => _value('productsSortNewest');
  String get productsStatusActive => _value('productsStatusActive');
  String get productsStatusInactive => _value('productsStatusInactive');
  String get productsStatusDraft => _value('productsStatusDraft');
  String get productsStockOut => _value('productsStockOut');
  String get productsStockUnknown => _value('productsStockUnknown');
  String get productsQuickActions => _value('productsQuickActions');
  String get productsActionToggleStatus => _value('productsActionToggleStatus');
  String get productsActionUpdateDiscount => _value('productsActionUpdateDiscount');
  String get productsActionUpdatePrice => _value('productsActionUpdatePrice');
  String get productsActionUpdateStock => _value('productsActionUpdateStock');
  String get productsStatusUpdated => _value('productsStatusUpdated');
  String get productsStatusUpdateFailed => _value('productsStatusUpdateFailed');
  String get productsDiscountDialogTitle => _value('productsDiscountDialogTitle');
  String get productsDiscountTypeLabel => _value('productsDiscountTypeLabel');
  String get productsDiscountTypeFixed => _value('productsDiscountTypeFixed');
  String get productsDiscountTypePercent => _value('productsDiscountTypePercent');
  String get productsDiscountAmountLabel => _value('productsDiscountAmountLabel');
  String get productsDiscountUpdated => _value('productsDiscountUpdated');
  String get productsDiscountUpdateFailed => _value('productsDiscountUpdateFailed');
  String get productsPriceDialogTitle => _value('productsPriceDialogTitle');
  String get productsPurchasePriceLabel => _value('productsPurchasePriceLabel');
  String get productsUnitPriceLabel => _value('productsUnitPriceLabel');
  String get productsPriceUpdated => _value('productsPriceUpdated');
  String get productsPriceUpdateFailed => _value('productsPriceUpdateFailed');
  String get productsStockDialogTitle => _value('productsStockDialogTitle');
  String get productsQuantityLabel => _value('productsQuantityLabel');
  String get productsStockUpdated => _value('productsStockUpdated');
  String get productsStockUpdateFailed => _value('productsStockUpdateFailed');
  String get productsVariationPriceDialogTitle =>
      _value('productsVariationPriceDialogTitle');
  String get productsVariationStockDialogTitle =>
      _value('productsVariationStockDialogTitle');
  String get productsVariationsEmpty => _value('productsVariationsEmpty');
  String get productsVariationCodeLabel => _value('productsVariationCodeLabel');
  String get productsAddVariation => _value('productsAddVariation');
  String get productsVariationsTitle => _value('productsVariationsTitle');
  String get productsDiscountTitle => _value('productsDiscountTitle');
  String get productsThumbnailTitle => _value('productsThumbnailTitle');
  String get productsThumbnailLabel => _value('productsThumbnailLabel');
  String get productsPermalinkLabel => _value('productsPermalinkLabel');
  String get productsTypeLabel => _value('productsTypeLabel');
  String get productsTypeSingle => _value('productsTypeSingle');
  String get productsTypeVariable => _value('productsTypeVariable');
  String get productsConditionLabel => _value('productsConditionLabel');
  String get productsFormNameRequired => _value('productsFormNameRequired');
  String get productsFormPermalinkRequired =>
      _value('productsFormPermalinkRequired');
  String get productsFormVariationRequired =>
      _value('productsFormVariationRequired');
  String get productsSaveFailed => _value('productsSaveFailed');
  String get productsDeleteFailed => _value('productsDeleteFailed');
  String get productsImageTooLarge => _value('productsImageTooLarge');
  String get productsImageUploadFailed => _value('productsImageUploadFailed');
  String get productsLoadFailed => _value('productsLoadFailed');
  String get productsEmptyMessage => _value('productsEmptyMessage');
  String get productsProductId => _value('productsProductId');
  String get productsUnnamed => _value('productsUnnamed');
  String get addProductTitle => _value('addProductTitle');
  String get addProductSaveDraft => _value('addProductSaveDraft');
  String get addProductDraftSavedMessage => _value('addProductDraftSavedMessage');
  String get addProductSubmittedMessage => _value('addProductSubmittedMessage');
  String get addProductStepBasics => _value('addProductStepBasics');
  String get addProductStepPricing => _value('addProductStepPricing');
  String get addProductStepMedia => _value('addProductStepMedia');
  String get addProductCancel => _value('addProductCancel');
  String get addProductBack => _value('addProductBack');
  String get addProductNext => _value('addProductNext');
  String get addProductPublish => _value('addProductPublish');
  String get addProductBasicsTitle => _value('addProductBasicsTitle');
  String get addProductBasicsSubtitle => _value('addProductBasicsSubtitle');
  String get addProductNameLabel => _value('addProductNameLabel');
  String get addProductSkuLabel => _value('addProductSkuLabel');
  String get addProductCategoryLabel => _value('addProductCategoryLabel');
  String get addProductCategoryPropertiesTitle =>
      _value('addProductCategoryPropertiesTitle');
  String get addProductCategoryPropertiesSubtitle =>
      _value('addProductCategoryPropertiesSubtitle');
  String get addProductDescriptionLabel => _value('addProductDescriptionLabel');
  String get addProductTagsTitle => _value('addProductTagsTitle');
  String get addProductTagBestseller => _value('addProductTagBestseller');
  String get addProductTagNew => _value('addProductTagNew');
  String get addProductTagOrganic => _value('addProductTagOrganic');
  String get addProductTagGiftable => _value('addProductTagGiftable');
  String get addProductTagLimited => _value('addProductTagLimited');
  String get addProductPropertySize => _value('addProductPropertySize');
  String get addProductPropertyColor => _value('addProductPropertyColor');
  String get addProductPropertyMaterial => _value('addProductPropertyMaterial');
  String get addProductPropertyFit => _value('addProductPropertyFit');
  String get addProductPropertyStyle => _value('addProductPropertyStyle');
  String get addProductPropertyStrap => _value('addProductPropertyStrap');
  String get addProductPricingTitle => _value('addProductPricingTitle');
  String get addProductPricingSubtitle => _value('addProductPricingSubtitle');
  String get addProductPriceLabel => _value('addProductPriceLabel');
  String get addProductCompareLabel => _value('addProductCompareLabel');
  String get addProductUnitLabel => _value('addProductUnitLabel');
  String get addProductUnitPiece => _value('addProductUnitPiece');
  String get addProductUnitBottle => _value('addProductUnitBottle');
  String get addProductUnitBox => _value('addProductUnitBox');
  String get addProductUnitSet => _value('addProductUnitSet');
  String get addProductTrackInventory => _value('addProductTrackInventory');
  String get addProductStockQuantity => _value('addProductStockQuantity');
  String get addProductLowStockAlert => _value('addProductLowStockAlert');
  String get addProductAllowBackorders => _value('addProductAllowBackorders');
  String get addProductFeatureProduct => _value('addProductFeatureProduct');
  String get addProductMediaTitle => _value('addProductMediaTitle');
  String get addProductMediaSubtitle => _value('addProductMediaSubtitle');
  String get addProductImagesTitle => _value('addProductImagesTitle');
  String get addProductImageCover => _value('addProductImageCover');
  String get addProductImagePickerMessage =>
      _value('addProductImagePickerMessage');
  String get addProductDeliveryTitle => _value('addProductDeliveryTitle');
  String get addProductDeliveryCourier => _value('addProductDeliveryCourier');
  String get addProductDeliveryPickup => _value('addProductDeliveryPickup');
  String get addProductDeliverySameDay => _value('addProductDeliverySameDay');
  String get addProductPublishToggle => _value('addProductPublishToggle');
  String get addProductPublishNote => _value('addProductPublishNote');
  String get addProductSizeMini => _value('addProductSizeMini');
  String get addProductSizeSmall => _value('addProductSizeSmall');
  String get addProductSizeMedium => _value('addProductSizeMedium');
  String get addProductSizeLarge => _value('addProductSizeLarge');
  String get addProductColorBlack => _value('addProductColorBlack');
  String get addProductColorWhite => _value('addProductColorWhite');
  String get addProductColorBeige => _value('addProductColorBeige');
  String get addProductColorBlue => _value('addProductColorBlue');
  String get addProductColorGreen => _value('addProductColorGreen');
  String get addProductColorRed => _value('addProductColorRed');
  String get addProductColorBrown => _value('addProductColorBrown');
  String get addProductColorGray => _value('addProductColorGray');
  String get addProductColorNavy => _value('addProductColorNavy');
  String get addProductColorOlive => _value('addProductColorOlive');
  String get addProductColorGold => _value('addProductColorGold');
  String get addProductColorSilver => _value('addProductColorSilver');
  String get addProductColorRose => _value('addProductColorRose');
  String get addProductColorPearl => _value('addProductColorPearl');
  String get addProductMaterialCotton => _value('addProductMaterialCotton');
  String get addProductMaterialLinen => _value('addProductMaterialLinen');
  String get addProductMaterialSilk => _value('addProductMaterialSilk');
  String get addProductMaterialDenim => _value('addProductMaterialDenim');
  String get addProductMaterialWool => _value('addProductMaterialWool');
  String get addProductMaterialLeather => _value('addProductMaterialLeather');
  String get addProductMaterialSuede => _value('addProductMaterialSuede');
  String get addProductMaterialCanvas => _value('addProductMaterialCanvas');
  String get addProductMaterialSynthetic => _value('addProductMaterialSynthetic');
  String get addProductMaterialNylon => _value('addProductMaterialNylon');
  String get addProductMaterialMetal => _value('addProductMaterialMetal');
  String get addProductMaterialFabric => _value('addProductMaterialFabric');
  String get addProductMaterialResin => _value('addProductMaterialResin');
  String get addProductFitSlim => _value('addProductFitSlim');
  String get addProductFitRegular => _value('addProductFitRegular');
  String get addProductFitRelaxed => _value('addProductFitRelaxed');
  String get addProductFitOversized => _value('addProductFitOversized');
  String get addProductStyleSneaker => _value('addProductStyleSneaker');
  String get addProductStyleLoafer => _value('addProductStyleLoafer');
  String get addProductStyleBoot => _value('addProductStyleBoot');
  String get addProductStyleHeel => _value('addProductStyleHeel');
  String get addProductStyleSandal => _value('addProductStyleSandal');
  String get addProductStyleMinimal => _value('addProductStyleMinimal');
  String get addProductStyleStatement => _value('addProductStyleStatement');
  String get addProductStyleClassic => _value('addProductStyleClassic');
  String get addProductStyleModern => _value('addProductStyleModern');
  String get addProductStrapShort => _value('addProductStrapShort');
  String get addProductStrapLong => _value('addProductStrapLong');
  String get addProductStrapAdjustable => _value('addProductStrapAdjustable');
  String get editProductTitle => _value('editProductTitle');
  String get editProductSaveAction => _value('editProductSaveAction');
  String get editProductDeleteAction => _value('editProductDeleteAction');
  String get editProductDeleteTitle => _value('editProductDeleteTitle');
  String get editProductDeleteMessage => _value('editProductDeleteMessage');
  String get editProductDeleteCancel => _value('editProductDeleteCancel');
  String get editProductDeleteConfirm => _value('editProductDeleteConfirm');
  String get editProductUpdatedMessage => _value('editProductUpdatedMessage');
  String get editProductDeletedMessage => _value('editProductDeletedMessage');
  String get drawerStoreProfileTitle => _value('drawerStoreProfileTitle');
  String get drawerStoreProfileSubtitle => _value('drawerStoreProfileSubtitle');
  String get drawerSettingsTitle => _value('drawerSettingsTitle');
  String get drawerSettingsSubtitle => _value('drawerSettingsSubtitle');
  String get drawerSupportTitle => _value('drawerSupportTitle');
  String get drawerSupportSubtitle => _value('drawerSupportSubtitle');
  String get drawerActive => _value('drawerActive');
  String get drawerLogOut => _value('drawerLogOut');
  String get drawerLogOutTitle => _value('drawerLogOutTitle');
  String get drawerLogOutMessage => _value('drawerLogOutMessage');
  String get drawerCancel => _value('drawerCancel');
  String get storeProfileTitle => _value('storeProfileTitle');
  String get storeProfileSubtitle => _value('storeProfileSubtitle');
  String get storeProfileLogoTitle => _value('storeProfileLogoTitle');
  String get storeProfileLogoHint => _value('storeProfileLogoHint');
  String get storeProfileLogoUpdateAction => _value('storeProfileLogoUpdateAction');
  String get storeProfileBannerLabel => _value('storeProfileBannerLabel');
  String get storeProfileBannerUpdateAction =>
      _value('storeProfileBannerUpdateAction');
  String get storeProfileDetailsTitle => _value('storeProfileDetailsTitle');
  String get storeProfileNameLabel => _value('storeProfileNameLabel');
  String get storeProfileNameHint => _value('storeProfileNameHint');
  String get storeProfileSlugLabel => _value('storeProfileSlugLabel');
  String get storeProfileSlugHint => _value('storeProfileSlugHint');
  String get storeProfileTaglineLabel => _value('storeProfileTaglineLabel');
  String get storeProfileDescriptionLabel => _value('storeProfileDescriptionLabel');
  String get storeProfileCategoryLabel => _value('storeProfileCategoryLabel');
  String get storeProfileContactTitle => _value('storeProfileContactTitle');
  String get storeProfileSellerPhoneLabel => _value('storeProfileSellerPhoneLabel');
  String get storeProfileSellerPhoneHint => _value('storeProfileSellerPhoneHint');
  String get storeProfileShopPhoneLabel => _value('storeProfileShopPhoneLabel');
  String get storeProfileShopPhoneHint => _value('storeProfileShopPhoneHint');
  String get storeProfilePhoneLabel => _value('storeProfilePhoneLabel');
  String get storeProfileEmailLabel => _value('storeProfileEmailLabel');
  String get storeProfileAddressLabel => _value('storeProfileAddressLabel');
  String get storeProfileAddressHint => _value('storeProfileAddressHint');
  String get storeProfileSeoTitle => _value('storeProfileSeoTitle');
  String get storeProfileMetaTitleLabel => _value('storeProfileMetaTitleLabel');
  String get storeProfileMetaTitleHint => _value('storeProfileMetaTitleHint');
  String get storeProfileMetaDescriptionLabel =>
      _value('storeProfileMetaDescriptionLabel');
  String get storeProfileMetaDescriptionHint =>
      _value('storeProfileMetaDescriptionHint');
  String get storeProfileMetaImageLabel => _value('storeProfileMetaImageLabel');
  String get storeProfileMetaImageUpdateAction =>
      _value('storeProfileMetaImageUpdateAction');
  String get storeProfileStatusTitle => _value('storeProfileStatusTitle');
  String get storeProfileStatusOpenTitle => _value('storeProfileStatusOpenTitle');
  String get storeProfileStatusOpenSubtitle => _value('storeProfileStatusOpenSubtitle');
  String get storeProfileStatusAcceptingTitle =>
      _value('storeProfileStatusAcceptingTitle');
  String get storeProfileStatusAcceptingSubtitle =>
      _value('storeProfileStatusAcceptingSubtitle');
  String get storeProfileStatusVacationTitle =>
      _value('storeProfileStatusVacationTitle');
  String get storeProfileStatusVacationSubtitle =>
      _value('storeProfileStatusVacationSubtitle');
  String get storeProfileStatusVacationNotice =>
      _value('storeProfileStatusVacationNotice');
  String get storeProfileFulfillmentTitle => _value('storeProfileFulfillmentTitle');
  String get storeProfilePickupTitle => _value('storeProfilePickupTitle');
  String get storeProfilePickupSubtitle => _value('storeProfilePickupSubtitle');
  String get storeProfileDeliveryTitle => _value('storeProfileDeliveryTitle');
  String get storeProfileDeliverySubtitle => _value('storeProfileDeliverySubtitle');
  String get storeProfilePrepTimeLabel => _value('storeProfilePrepTimeLabel');
  String get storeProfileBusinessHoursTitle => _value('storeProfileBusinessHoursTitle');
  String get storeProfilePreviewAction => _value('storeProfilePreviewAction');
  String get storeProfileSaveAction => _value('storeProfileSaveAction');
  String get storeProfileSavedMessage => _value('storeProfileSavedMessage');
  String get storeProfilePreviewMessage => _value('storeProfilePreviewMessage');
  String get storeProfileImageUpdatedMessage =>
      _value('storeProfileImageUpdatedMessage');
  String get storeProfileImageUpdateFailed =>
      _value('storeProfileImageUpdateFailed');
  String get storeProfileImagePickFailed => _value('storeProfileImagePickFailed');
  String get storeProfileImageTooLarge => _value('storeProfileImageTooLarge');
  String get storeProfileAuthRequired => _value('storeProfileAuthRequired');
  String get storeProfileLoadFailed => _value('storeProfileLoadFailed');
  String get storeProfileUpdateFailed => _value('storeProfileUpdateFailed');
  String get storeProfileNameRequired => _value('storeProfileNameRequired');
  String get storeProfileShopPhoneRequired => _value('storeProfileShopPhoneRequired');
  String get storeProfileSlugRequired => _value('storeProfileSlugRequired');
  String get storeProfileCategorySkincare => _value('storeProfileCategorySkincare');
  String get storeProfileCategoryFragrance =>
      _value('storeProfileCategoryFragrance');
  String get storeProfileCategoryBeauty => _value('storeProfileCategoryBeauty');
  String get storeProfileCategoryAccessories =>
      _value('storeProfileCategoryAccessories');
  String get storeProfilePrepSameDay => _value('storeProfilePrepSameDay');
  String get storeProfilePrep1to2Days => _value('storeProfilePrep1to2Days');
  String get storeProfilePrep3to5Days => _value('storeProfilePrep3to5Days');
  String get storeProfileDayMon => _value('storeProfileDayMon');
  String get storeProfileDayTue => _value('storeProfileDayTue');
  String get storeProfileDayWed => _value('storeProfileDayWed');
  String get storeProfileDayThu => _value('storeProfileDayThu');
  String get storeProfileDayFri => _value('storeProfileDayFri');
  String get storeProfileDaySat => _value('storeProfileDaySat');
  String get storeProfileDaySun => _value('storeProfileDaySun');
  String get storeProfileHoursRegular => _value('storeProfileHoursRegular');
  String get storeProfileHoursLate => _value('storeProfileHoursLate');
  String get storeProfileHoursFriday => _value('storeProfileHoursFriday');
  String get storeProfileHoursWeekend => _value('storeProfileHoursWeekend');
  String get storeProfileHoursClosed => _value('storeProfileHoursClosed');
  String get settingsTitle => _value('settingsTitle');
  String get settingsSubtitle => _value('settingsSubtitle');
  String get settingsNotificationsTitle => _value('settingsNotificationsTitle');
  String get settingsOrderUpdatesTitle => _value('settingsOrderUpdatesTitle');
  String get settingsOrderUpdatesSubtitle =>
      _value('settingsOrderUpdatesSubtitle');
  String get settingsPayoutUpdatesTitle => _value('settingsPayoutUpdatesTitle');
  String get settingsPayoutUpdatesSubtitle =>
      _value('settingsPayoutUpdatesSubtitle');
  String get settingsLowStockAlertsTitle =>
      _value('settingsLowStockAlertsTitle');
  String get settingsLowStockAlertsSubtitle =>
      _value('settingsLowStockAlertsSubtitle');
  String get settingsMarketingUpdatesTitle =>
      _value('settingsMarketingUpdatesTitle');
  String get settingsMarketingUpdatesSubtitle =>
      _value('settingsMarketingUpdatesSubtitle');
  String get settingsSecurityTitle => _value('settingsSecurityTitle');
  String get settingsTwoFactorTitle => _value('settingsTwoFactorTitle');
  String get settingsTwoFactorSubtitle => _value('settingsTwoFactorSubtitle');
  String get settingsBiometricTitle => _value('settingsBiometricTitle');
  String get settingsBiometricSubtitle => _value('settingsBiometricSubtitle');
  String get settingsChangePasswordTitle =>
      _value('settingsChangePasswordTitle');
  String get settingsChangePasswordSubtitle =>
      _value('settingsChangePasswordSubtitle');
  String get settingsPasswordComingSoonMessage =>
      _value('settingsPasswordComingSoonMessage');
  String get settingsPreferencesTitle => _value('settingsPreferencesTitle');
  String get settingsLanguageLabel => _value('settingsLanguageLabel');
  String get settingsCurrencyLabel => _value('settingsCurrencyLabel');
  String get settingsTimeZoneLabel => _value('settingsTimeZoneLabel');
  String get settingsLanguageEnglish => _value('settingsLanguageEnglish');
  String get settingsLanguageArabic => _value('settingsLanguageArabic');
  String get settingsAccountTitle => _value('settingsAccountTitle');
  String get settingsTeamMembersTitle => _value('settingsTeamMembersTitle');
  String get settingsTeamMembersSubtitle =>
      _value('settingsTeamMembersSubtitle');
  String get settingsTeamComingSoonMessage =>
      _value('settingsTeamComingSoonMessage');
  String get settingsBillingTitle => _value('settingsBillingTitle');
  String get settingsBillingSubtitle => _value('settingsBillingSubtitle');
  String get settingsBillingComingSoonMessage =>
      _value('settingsBillingComingSoonMessage');
  String get settingsHelpCenterTitle => _value('settingsHelpCenterTitle');
  String get settingsHelpCenterSubtitle =>
      _value('settingsHelpCenterSubtitle');
  String get settingsHelpCenterComingSoonMessage =>
      _value('settingsHelpCenterComingSoonMessage');
  String get settingsPlansTitle => _value('settingsPlansTitle');
  String get settingsPlansSubtitle => _value('settingsPlansSubtitle');
  String get subscriptionPlansTitle => _value('subscriptionPlansTitle');
  String get subscriptionPlansSubtitle => _value('subscriptionPlansSubtitle');
  String get subscriptionPlansSectionTitle => _value('subscriptionPlansSectionTitle');
  String get subscriptionCurrentLabel => _value('subscriptionCurrentLabel');
  String get subscriptionRecommendedBadge =>
      _value('subscriptionRecommendedBadge');
  String get subscriptionFreeName => _value('subscriptionFreeName');
  String get subscriptionPlusName => _value('subscriptionPlusName');
  String get subscriptionProName => _value('subscriptionProName');
  String get subscriptionFreeDescription =>
      _value('subscriptionFreeDescription');
  String get subscriptionPlusDescription =>
      _value('subscriptionPlusDescription');
  String get subscriptionProDescription => _value('subscriptionProDescription');
  String get subscriptionFreePrice => _value('subscriptionFreePrice');
  String get subscriptionPlusPrice => _value('subscriptionPlusPrice');
  String get subscriptionProPrice => _value('subscriptionProPrice');
  String get subscriptionPerMonth => _value('subscriptionPerMonth');
  String get subscriptionForever => _value('subscriptionForever');
  String get subscriptionProductsUnlimited =>
      _value('subscriptionProductsUnlimited');
  String get subscriptionItemsUnlimited =>
      _value('subscriptionItemsUnlimited');
  String get subscriptionBasicAnalytics => _value('subscriptionBasicAnalytics');
  String get subscriptionAdvancedAnalytics =>
      _value('subscriptionAdvancedAnalytics');
  String get subscriptionCustomInsights => _value('subscriptionCustomInsights');
  String get subscriptionEmailSupport => _value('subscriptionEmailSupport');
  String get subscriptionPrioritySupport => _value('subscriptionPrioritySupport');
  String get subscriptionDedicatedSuccess =>
      _value('subscriptionDedicatedSuccess');
  String get subscriptionChooseAction => _value('subscriptionChooseAction');
  String get subscriptionCurrentAction => _value('subscriptionCurrentAction');
  String get subscriptionChangeMessage => _value('subscriptionChangeMessage');
  String get subscriptionCurrentHint => _value('subscriptionCurrentHint');
  String get subscriptionFooterNote => _value('subscriptionFooterNote');
  String get subscriptionConfirmSubtitle => _value('subscriptionConfirmSubtitle');
  String get subscriptionConfirmAction => _value('subscriptionConfirmAction');
  String get ordersSearchHint => _value('ordersSearchHint');
  String get ordersFilterTitle => _value('ordersFilterTitle');
  String get ordersFilterPaymentTitle => _value('ordersFilterPaymentTitle');
  String get ordersFilterDeliveryTitle => _value('ordersFilterDeliveryTitle');
  String get ordersFilterPayoutTitle => _value('ordersFilterPayoutTitle');
  String get ordersFilterLocationTitle => _value('ordersFilterLocationTitle');
  String get ordersFilterPriorityOnly => _value('ordersFilterPriorityOnly');
  String get ordersFilterClearAction => _value('ordersFilterClearAction');
  String get ordersFilterApplyAction => _value('ordersFilterApplyAction');
  String get ordersFilterAll => _value('ordersFilterAll');
  String get ordersEmptyFiltered => _value('ordersEmptyFiltered');
  String get ordersEmpty => _value('ordersEmpty');
  String get ordersLoadFailed => _value('ordersLoadFailed');
  String get ordersCountersFailed => _value('ordersCountersFailed');
  String get ordersSortLatest => _value('ordersSortLatest');
  String get ordersPriorityBadge => _value('ordersPriorityBadge');
  String get ordersStatusNew => _value('ordersStatusNew');
  String get ordersStatusPending => _value('ordersStatusPending');
  String get ordersStatusProcessing => _value('ordersStatusProcessing');
  String get ordersStatusReady => _value('ordersStatusReady');
  String get ordersStatusReadyToShip => _value('ordersStatusReadyToShip');
  String get ordersStatusShipped => _value('ordersStatusShipped');
  String get ordersStatusDelivered => _value('ordersStatusDelivered');
  String get ordersStatusCancelled => _value('ordersStatusCancelled');
  String get ordersPaymentCard => _value('ordersPaymentCard');
  String get ordersPaymentCash => _value('ordersPaymentCash');
  String get ordersPaymentWallet => _value('ordersPaymentWallet');
  String get ordersPaymentStatusPaid => _value('ordersPaymentStatusPaid');
  String get ordersPaymentStatusUnpaid => _value('ordersPaymentStatusUnpaid');
  String get ordersPaymentStatusRefunded => _value('ordersPaymentStatusRefunded');
  String get ordersPaymentCashOnDelivery => _value('ordersPaymentCashOnDelivery');
  String get ordersDeliveryCourier => _value('ordersDeliveryCourier');
  String get ordersDeliveryPickup => _value('ordersDeliveryPickup');
  String get ordersPayoutPending => _value('ordersPayoutPending');
  String get ordersPayoutHold => _value('ordersPayoutHold');
  String get ordersPayoutScheduled => _value('ordersPayoutScheduled');
  String get ordersPayoutPaid => _value('ordersPayoutPaid');
  String get ordersPayoutRefunded => _value('ordersPayoutRefunded');
  String get ordersLocationRiyadh => _value('ordersLocationRiyadh');
  String get ordersLocationDiriyah => _value('ordersLocationDiriyah');
  String get ordersUnknownCustomer => _value('ordersUnknownCustomer');
  String get ordersDetailsTitle => _value('ordersDetailsTitle');
  String get ordersDetailsLoadFailed => _value('ordersDetailsLoadFailed');
  String get ordersDetailsSummaryTitle => _value('ordersDetailsSummaryTitle');
  String get ordersDetailsCustomerLabel => _value('ordersDetailsCustomerLabel');
  String get ordersDetailsItemsLabel => _value('ordersDetailsItemsLabel');
  String get ordersDetailsItemsTitle => _value('ordersDetailsItemsTitle');
  String get ordersDetailsOptionSize => _value('ordersDetailsOptionSize');
  String get ordersDetailsOptionColor => _value('ordersDetailsOptionColor');
  String get ordersDetailsTotalLabel => _value('ordersDetailsTotalLabel');
  String get ordersDetailsPaymentLabel => _value('ordersDetailsPaymentLabel');
  String get ordersDetailsDeliveryLabel => _value('ordersDetailsDeliveryLabel');
  String get ordersDetailsPayoutLabel => _value('ordersDetailsPayoutLabel');
  String get ordersDetailsLocationLabel => _value('ordersDetailsLocationLabel');
  String get ordersDetailsPlacedLabel => _value('ordersDetailsPlacedLabel');
  String get ordersDetailsStatusTitle => _value('ordersDetailsStatusTitle');
  String get ordersDetailsPriorityToggle => _value('ordersDetailsPriorityToggle');
  String get ordersDetailsAssignmentTitle => _value('ordersDetailsAssignmentTitle');
  String get ordersDetailsDeliveryCompanyLabel =>
      _value('ordersDetailsDeliveryCompanyLabel');
  String get ordersDetailsAssignmentHint =>
      _value('ordersDetailsAssignmentHint');
  String get ordersDetailsAssignmentUnassigned =>
      _value('ordersDetailsAssignmentUnassigned');
  String get ordersDetailsAssignmentPickupNote =>
      _value('ordersDetailsAssignmentPickupNote');
  String get ordersDetailsNotesTitle => _value('ordersDetailsNotesTitle');
  String get ordersDetailsNotesHint => _value('ordersDetailsNotesHint');
  String get ordersDetailsSaveAction => _value('ordersDetailsSaveAction');
  String get ordersDetailsSavedMessage => _value('ordersDetailsSavedMessage');
  String get ordersDetailsRejectAction => _value('ordersDetailsRejectAction');
  String get ordersDetailsRejectTitle => _value('ordersDetailsRejectTitle');
  String get ordersDetailsRejectMessage => _value('ordersDetailsRejectMessage');
  String get ordersDetailsRejectCancel => _value('ordersDetailsRejectCancel');
  String get ordersDetailsRejectConfirm => _value('ordersDetailsRejectConfirm');
  String get ordersDetailsRejectedMessage =>
      _value('ordersDetailsRejectedMessage');
  String get ordersStatusUpdateFailed => _value('ordersStatusUpdateFailed');
  String get ordersAcceptAction => _value('ordersAcceptAction');
  String get ordersAcceptSuccess => _value('ordersAcceptSuccess');
  String get ordersAcceptFailed => _value('ordersAcceptFailed');
  String get ordersCancelSuccess => _value('ordersCancelSuccess');
  String get ordersCancelFailed => _value('ordersCancelFailed');
  String get ordersStatusInvalidDeliveredUnpaid =>
      _value('ordersStatusInvalidDeliveredUnpaid');
  String get ordersDetailsDeliveryPartnerFalcon =>
      _value('ordersDetailsDeliveryPartnerFalcon');
  String get ordersDetailsDeliveryPartnerSwift =>
      _value('ordersDetailsDeliveryPartnerSwift');
  String get ordersDetailsDeliveryPartnerDesertGo =>
      _value('ordersDetailsDeliveryPartnerDesertGo');

  String registerOtpInstruction(String phone) {
    final template = _value('registerOtpInstruction');
    return template.replaceAll('{phone}', phone);
  }

  String registerOtpSentTo(String phone) {
    final template = _value('registerOtpSentTo');
    return template.replaceAll('{phone}', phone);
  }

  String welcomeStepIndicator(int current, int total) {
    final template = _value('welcomeStepIndicator');
    return template
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString());
  }

  String addProductStepIndicator(int current, int total) {
    final template = _value('addProductStepIndicator');
    return template
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString());
  }

  String addProductImageLabel(int index) {
    final template = _value('addProductImageLabel');
    return template.replaceAll('{index}', index.toString());
  }

  String homeOrderItemsLine(int count, String total) {
    final template = _value('homeOrderItemsLine');
    return template
        .replaceAll('{count}', count.toString())
        .replaceAll('{total}', total);
  }

  String statsSoldCount(int count) {
    final template = _value('statsSoldCount');
    return template.replaceAll('{count}', count.toString());
  }

  String subscriptionProductsLimit(int count) {
    final template = _value('subscriptionProductsLimit');
    return template.replaceAll('{count}', count.toString());
  }

  String subscriptionItemsLimit(int count) {
    final template = _value('subscriptionItemsLimit');
    return template.replaceAll('{count}', count.toString());
  }

  String subscriptionCurrentSummary(String plan) {
    final template = _value('subscriptionCurrentSummary');
    return template.replaceAll('{plan}', plan);
  }

  String subscriptionConfirmTitle(String plan) {
    final template = _value('subscriptionConfirmTitle');
    return template.replaceAll('{plan}', plan);
  }

  String subscriptionUpdatedMessage(String plan) {
    final template = _value('subscriptionUpdatedMessage');
    return template.replaceAll('{plan}', plan);
  }

  String productsListTitle(int count) {
    final template = _value('productsListTitle');
    return template.replaceAll('{count}', count.toString());
  }

  String productsStockLow(int count) {
    final template = _value('productsStockLow');
    return template.replaceAll('{count}', count.toString());
  }

  String productsStockAvailable(int count) {
    final template = _value('productsStockAvailable');
    return template.replaceAll('{count}', count.toString());
  }

  String productsVariationLabel(int index) {
    final template = _value('productsVariationLabel');
    return template.replaceAll('{index}', index.toString());
  }

  String ordersListTitle(int count) {
    final template = _value('ordersListTitle');
    return template.replaceAll('{count}', count.toString());
  }

  String ordersItemsLine(int count, String total) {
    final template = _value('ordersItemsLine');
    return template
        .replaceAll('{count}', count.toString())
        .replaceAll('{total}', total);
  }

  String ordersItemsCount(int count) {
    final template = _value('ordersItemsCount');
    return template.replaceAll('{count}', count.toString());
  }

  String ordersDetailsItemQuantity(int count) {
    final template = _value('ordersDetailsItemQuantity');
    return template.replaceAll('{count}', count.toString());
  }

  String ordersDetailsItemUnitPrice(String price) {
    final template = _value('ordersDetailsItemUnitPrice');
    return template.replaceAll('{price}', price);
  }

  String ordersPaymentCombined(String method, String status) {
    final template = _value('ordersPaymentCombined');
    return template
        .replaceAll('{method}', method)
        .replaceAll('{status}', status);
  }

  String ordersTimeMinutesAgo(int count) {
    final template = _value('ordersTimeMinutesAgo');
    return template.replaceAll('{count}', count.toString());
  }

  String ordersTimeHoursAgo(int count) {
    final template = _value('ordersTimeHoursAgo');
    return template.replaceAll('{count}', count.toString());
  }

  String drawerComingSoon(String label) {
    final template = _value('drawerComingSoon');
    return template.replaceAll('{label}', label);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
