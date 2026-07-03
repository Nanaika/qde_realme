abstract class AuthRepository {
  Future login();
  Future logout();
  Future getCurrentUser(String id);
}
