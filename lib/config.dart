class AppConfig {
  // App
  static const String appName = 'Rolly';

  // API
  static const String apiBaseUrl = 'http://localhost:8080';

  // endpoints
  static const String loginEndpoint = '$apiBaseUrl/auth/login';
  static const String registerEndpoint = '$apiBaseUrl/auth/reg';
  static const String measurementsEndpoint = '$apiBaseUrl/user/meas';
  static const String getCategoryEndpoint = '$apiBaseUrl/trick/categories';
  static const String trickByCategoryEndpoint = '$apiBaseUrl/trick/by-cat';
  static const String userResponse = '$apiBaseUrl/user/profile';
  static const String changePasswd = '$apiBaseUrl/user/change-password';
  static const String trickEndpoint = '$apiBaseUrl/trick';
  static const String resetTrickEndpoint = '$apiBaseUrl/trick/reset';
  static const String trainingPlans = '$apiBaseUrl/training';
  static const String addRoute = '$apiBaseUrl/route/create';

  // img
  static const String logoImg = 'assets/images/logo.svg';
  static const String logoLightImg = 'assets/images/logo-light.svg';

}
