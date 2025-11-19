class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://shakita-unlacquered-nakita.ngrok-free.dev/';
  
  // API Endpoints
  static const String login = 'barbers/login';
  static const String register = 'barbers/register';
  static const String refreshToken = '/refresh';
  static const String logout = '/logout';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Third-party API keys (replace with your actual keys)
  static const String stripePublishableKey = 'pk_test_your_stripe_key_here';
  static const String stripeSecretKey = 'sk_test_your_stripe_secret_here';
  
  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Convenience header values and logging flag used by BaseApiService
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const bool enableApiLogging = false; // Set to true to force API logging even outside debug mode
}
