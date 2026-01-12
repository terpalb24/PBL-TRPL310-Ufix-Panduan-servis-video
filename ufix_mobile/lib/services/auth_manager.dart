import 'package:ufix_mobile/models/user_model.dart';

class AuthManager {
  static User? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void setUser(User user) {
    currentUser = user;
  }

  static void clear() {
    currentUser = null;
  }
}
