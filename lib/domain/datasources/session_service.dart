import '../entities/user.dart';

class SessionService {
  static final SessionService instance = SessionService._init();
  SessionService._init();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }
}