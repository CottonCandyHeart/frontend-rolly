class AppConfig {
  // adres API
  static const String apiBaseUrl = 'localhost:8080';

  // endpointy
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String registerEndpoint = '$apiBaseUrl/auth/reg';
}
