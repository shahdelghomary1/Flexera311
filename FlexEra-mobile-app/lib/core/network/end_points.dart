class EndPoints {
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String googleLogin = 'auth/google/flutter';
  static const String doctors = 'auth/authdoctors';
  static const String doctorSchedule = 'auth/doctor-schedule';
  static const String logout = 'auth/logout';
  static const String updateAccount = 'auth/authaccount';
  static const String myExercises = 'auth/my-exercises';
  static const String isCompleted = 'exercises/toggle';
  static const String doctorLogin = 'doctors/login';
  static const String doctorAccount = 'doctors/account';
  static const String schedule = 'schedule';
  static const String myAppointments = 'schedule/my-appointments';
  static const String doctorUsers = 'doctors/users';

  static String userExercises(String userId) =>
      '$doctorUsers/$userId/exercises';

  static String userExercise(String userId, String exerciseId) =>
      '$doctorUsers/$userId/exercises/$exerciseId';

  static String userFullProfile(String userId) => 'doctors/user/$userId/full';

  static String specificExercise(String userId, String exerciseId) =>
      '$doctorUsers/$userId/exercises/$exerciseId';
  static const String doctorSignup = 'doctors/signup';
  static const String userForgotPassword = 'auth/forgot-password';
  static const String userVerifyOtp = 'auth/verify-otp';
  static const String userResetPassword = 'auth/reset-password';
  static const String doctorForgotPassword = 'doctors/forgot-password';
  static const String doctorVerifyOtp = 'doctors/verify-otp';
  static const String doctorResetPassword = 'doctors/reset-password';
  static const String paymobInit = 'paymob/init';
  static const String upcomingPaidAppointments =
      'doctors/upcoming-paid-appointments';
  static const String pastPaidAppointments = 'doctors/past-paid-appointments';
  static const String authSummary = 'auth/summary';
  static const String getNotifications = 'notifications';
  static String deleteNotification(String id) => 'notifications/$id';
  static String markNotificationRead(String id) => 'notifications/$id/read';
}
