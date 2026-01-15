class AppConstants {
  static const String appName = 'Mobile App';
  static const String appVersion = '1.0.0';

  static const int apiTimeout = 30000;
  static const int maxRetryCount = 3;
  static const int pollingInterval = 3000;
  static const int pollingTimeout = 300000;

  static const int verificationCodeCountdown = 60;
  static const int minPasswordLength = 8;
  static const int maxImageSize = 2 * 1024 * 1024;

  static const int defaultPhotoCount = 3;
  static const int minPhotoCount = 1;
  static const int maxPhotoCount = 10;

  static const int targetFps = 60;
  static const int maxMemoryMB = 200;
  static const int maxStartupTimeSeconds = 3;
}

class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendVerificationCode = '/auth/send-code';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  static const String rechargePackages = '/recharge/packages';
  static const String rechargeHistory = '/recharge/history';
  static const String createPayment = '/payment/create';
  static const String paymentStatus = '/payment/status';

  static const String aiPhotoStyles = '/ai-photo/styles';
  static const String uploadPhoto = '/ai-photo/upload';
  static const String generatePhoto = '/ai-photo/generate';
  static const String generationStatus = '/ai-photo/status';
  static const String downloadPhoto = '/ai-photo/download';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String isLoggedIn = 'is_logged_in';
  static const String themeMode = 'theme_mode';
  static const String photoPreferences = 'photo_preferences';
}

class PaymentTypes {
  static const String stripe = 'stripe';
  static const String payme = 'payme';
}

class GenerationStatus {
  static const String queued = 'queued';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}
