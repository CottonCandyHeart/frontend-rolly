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
  static const String removeUser = '$userEndpoint/remove';

  static const String adminEndpoint = '$apiBaseUrl/admin';
  static const String chackAdminRole = '$adminEndpoint/isAdmin';
  static const String getAllUsers = '$adminEndpoint/all';
  static const String adminAaddlUser = '$adminEndpoint/add';
  static const String changeRole = '$adminEndpoint/role';
  static const String adminDeleteEvent = '$adminEndpoint/del/event';

  static const String trickEndpoint = '$apiBaseUrl/trick';
  static const String resetTrickEndpoint = '$trickEndpoint/reset';
  static const String getCategoryEndpoint = '$trickEndpoint/categories';
  static const String trickByCategoryEndpoint = '$trickEndpoint/by-cat';

  static const String trainingPlans = '$apiBaseUrl/training';
  static const String addTrainingPlan = '$trainingPlans/add';
  static const String markCompletedTrainingPlan = '$trainingPlans/mark';
  static const String updateTrainingPlan = '$trainingPlans/modify';
  static const String getTrainingPlansForToday = '$trainingPlans/d';

  static const String rEndpoint = '$apiBaseUrl/route';
  static const String routeEndpoint = '$rEndpoint/';
  static const String addRoute = '$rEndpoint/create';
  static const String getRouteByMonth = '$rEndpoint/m';

  static const String notificationEndpoint = '$apiBaseUrl/notification';
  static const String addNotification = '$notificationEndpoint/add';
  static const String removeNotification = '$notificationEndpoint/remove';
  static const String markAsRead = '$notificationEndpoint/read';

  static const String eventEndpoint = '$apiBaseUrl/event';
  static const String getEventByCity = '$eventEndpoint/c';
  static const String getUserEvents = '$eventEndpoint/u';
  static const String getParticipants = '$eventEndpoint/participants';
  static const String deleteEvent = '$eventEndpoint/del';
  static const String checkOwner = '$eventEndpoint/check';
  static const String checkAttendee = '$checkOwner/at';
  static const String getUserAttendedEvents = '$eventEndpoint/up';
  static const String getUserAttendedEventsForToday = '$eventEndpoint/d';
  static const String getAllEvents = '$eventEndpoint/get/all';

  static const String locationEndpoint = '$apiBaseUrl/locations';
  static const String addLocation = '$locationEndpoint/add';
  static const String getLocations = '$locationEndpoint/';
  static const String getLocationByName = '$locationEndpoint/get';

  static const String roleEndpoint = '$apiBaseUrl/role';
  static const String getAllRoles = '$roleEndpoint/';
  static const String addRole = '$roleEndpoint/add';

  // img
  static const String logoImg = 'assets/images/logo.svg';
  static const String logoLightImg = 'assets/images/logo-light.svg';

  // keys
  static const String kTrainingReminder = 'training_reminder_enabled';
  static final int trainingNotificationId = 'training_reminder'.hashCode;

}
