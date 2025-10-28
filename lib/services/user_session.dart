// user_session.dart

class UserSession {
  // Singleton setup
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // This holds the logged-in user's data
  Map<String, dynamic>? currentUser;

  // Call this when logging out
  void logout() {
    currentUser = null;
  }
}