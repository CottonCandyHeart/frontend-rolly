class AppConfig {
  // App
  static const String appName = 'Rolly';

  // adres API
  static const String apiBaseUrl = 'http://localhost:8080';

  // endpointy
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String registerEndpoint = '$apiBaseUrl/auth/reg';
  static const String measurementsEndpoint = '$apiBaseUrl/user/meas';

  // img
  static const String logoImg = 'assets/images/logo.svg';
  static const String logoLightImg = 'assets/images/logo-light.svg';

}
