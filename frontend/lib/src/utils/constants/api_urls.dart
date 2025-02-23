class Endpoints {
  // Base URL
  static const devUrl = "http://172.16.0.2:3000";
  static const String prodUrl = 'https://dentakoas-production.up.railway.app';

  static const String baseUrl =
      '$prodUrl/api';

  static const String baseAuthUrl = '$baseUrl/auth';
  static const String baseAuthSignin = '$baseAuthUrl/signin';

  // Authentication Endpoints
  static const String signinWithCredentials = '$baseAuthSignin/credentials';
  static const String signinWithGoogle = '$baseAuthSignin/google';
  static const String signinWithFacebook = '$baseAuthSignin/facebook';
  static const String signinWithApple = '$baseAuthSignin/apple'; 
  static const String signinWithGithub = '$baseAuthSignin/github';

  static const String signup = '$baseAuthUrl/signup';
  static const String sendVerificationEmail =
      '$baseAuthUrl/send-verification-email';
  static const String createNewVerificationToken =
      '$baseAuthUrl/new-verification';
  static const String verifyEmail = '$baseAuthUrl/email-verify';
  static const String sendEmailResetPassword = '$baseAuthUrl/reset-password';
  static const String compareOtpResetPassword = '$baseAuthUrl/verification-otp';

  static String isEmailExist(String email) =>
      '$baseUrl/users/is-email-exist?email=$email';

  static const String session = '$baseAuthUrl/session';
  static const String csrf = '$baseAuthUrl/csrf';

  static const String signout = '$baseAuthUrl/signout';

  // User Endpoints
  static const String users = '$baseUrl/users';
  static String userDetail(String id) => '$baseUrl/users/$id';
  static String userProfile(String id) => '$baseUrl/users/$id/profile';
  static String resetPassword(String id) => '$baseUrl/users/$id/reset-password';
  static String deleteAccount(String id) => '$baseUrl/users/$id';
  static String userWithRole(String role) => '$baseUrl/users?role=$role';

  // University Endpoints
  static const String universities = '$baseUrl/universities';
  static String university(String id) => '$baseUrl/universities/$id';

  // Post Endpoints
  static const String posts = '$baseUrl/posts';
  static String post(String postId) => '$baseUrl/posts/$postId';
  static String postWithSpecificUser(String id) => '$baseUrl/users/$id/posts';
  static String postWithSpecificUserAndPostId(String id, String postId) =>
      '$baseUrl/users/$id/posts/$postId';
  static String deleteSpecificPost(String id, String postId) =>
      '$baseUrl/users/$id/posts/$postId';
  static String likePost(String postId) => '$baseUrl/posts/$postId/likes';

  // Schedule Endpoints
  static const String schedules = '$baseUrl/schedules';
  static String schedule(String id) => '$baseUrl/schedules/$id';
  static String scheduleAvailability(String id) =>
      '$baseUrl/schedules/$id/availability';
  

  // Timeslot Endpoints
  static const String timeslots = '$baseUrl/timeslots';
  static String timeslot(String id) => '$baseUrl/timeslots/$id';

  // Appointment Endpoints
  static const String appointments = '$baseUrl/appointments';
  static String appointment(String id) => '$baseUrl/appointments/$id';
  static String appointmentWithSpecificUser(String userId) =>
      '$baseUrl/users/$userId/appointments';


  // Review Endpoints
  static const String reviews = '$baseUrl/reviews';
  static String review(String id) => '$baseUrl/reviews/$id';
  static String reviewWithSpecificUser(String userId) =>
      '$baseUrl/users/$userId/reviews';
  // static String reviewWithSpecificUserAndPost(String userId, String postId) =>
  //     '$baseUrl/review/$userId/post/$postId';

  // Notification Endpoints
  static String notificationsUser(String id) => '$baseUrl/users/$id/notifications';
  static String notifications = '$baseUrl/notifications';
  static String notification(String id) => '$baseUrl/notifications/$id';
  // static String createNotification(String id) =>
  //     '$baseUrl/users/$id/notifications';

  // Treatment Endpoints
  static const String treatments = '$baseUrl/treatments';
}
