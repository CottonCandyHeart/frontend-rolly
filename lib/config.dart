class AppConfig {
  // App
  static const String appName = 'Rolly';

  // API
  static const String apiBaseUrl = 'http://localhost:8080';

  // endpoints
  static const String authEndpoint = '$apiBaseUrl/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/reg';

  static const String userEndpoint = '$apiBaseUrl/user';
  static const String userResponse = '$userEndpoint/profile';
  static const String measurementsEndpoint = '$userEndpoint/meas';
  static const String changePasswd = '$userEndpoint/change-password';

  static const String trickEndpoint = '$apiBaseUrl/trick';
  static const String resetTrickEndpoint = '$trickEndpoint/reset';
  static const String getCategoryEndpoint = '$trickEndpoint/categories';
  static const String trickByCategoryEndpoint = '$trickEndpoint/by-cat';

  static const String trainingPlans = '$apiBaseUrl/training';
  static const String addTrainingPlan = '$trainingPlans/add';
  static const String markCompletedTrainingPlan = '$trainingPlans/mark';

  static const String rEndpoint = '$apiBaseUrl/route';
  static const String routeEndpoint = '$rEndpoint/';
  static const String addRoute = '$rEndpoint/create';
  static const String getRouteByMonth = '$rEndpoint/m';

  // img
  static const String logoImg = 'assets/images/logo.svg';
  static const String logoLightImg = 'assets/images/logo-light.svg';

}
