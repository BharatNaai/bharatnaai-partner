class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.example.com';
  static const String authBaseUrl = '$baseUrl/auth';
  static const String userBaseUrl = '$baseUrl/user';
  static const String patientBaseUrl = '$baseUrl/patient';
  static const String transcriptionBaseUrl = '$baseUrl/transcription';
  
  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String refreshTokenEndpoint = '/refresh';
  static const String logoutEndpoint = '/logout';
  static const String forgotPasswordEndpoint = '/forgot-password';
  static const String resetPasswordEndpoint = '/reset-password';
  
  // Patient endpoints
  static const String patientsEndpoint = '/patients';
  static const String addPatientEndpoint = '/patients/add';
  static const String updatePatientEndpoint = '/patients/update';
  static const String deletePatientEndpoint = '/patients/delete';
  
  // Transcription endpoints
  static const String transcribeEndpoint = '/transcribe';
  static const String saveTranscriptionEndpoint = '/transcription/save';
  
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
}
