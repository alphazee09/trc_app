class AppConstants {
  static const String appName = 'Alphazee09';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Crypto Wallet';
  
  // API Configuration
  static const String baseUrl = 'https://e5h6i7cdz0d9.manus.space/api';
  static const String localUrl = 'http://localhost:5001/api';
  static const String adminKey = 'alphazee09_admin_2024';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String biometricKey = 'biometric_enabled';
  static const String walletKey = 'wallet_data';
  
  // Crypto Currencies
  static const List<String> supportedCurrencies = ['BTC', 'USDT', 'ETH'];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 8.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 56.0;
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 32.0;
  
  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String invalidCredentials = 'Invalid credentials';
  static const String biometricNotAvailable = 'Biometric authentication not available';
  
  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String transactionSuccess = 'Transaction completed successfully';
  static const String kycSubmitted = 'KYC documents submitted successfully';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  
  // Crypto Addresses
  static const String btcAddressPattern = r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$';
  static const String ethAddressPattern = r'^0x[a-fA-F0-9]{40}$';
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
}

