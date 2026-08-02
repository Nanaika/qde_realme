abstract class AuthRepository {
  Future login();
  Future logout();
  Future deleteUser(String id);
  Future getCurrentUser(String id);
  Future<bool> getOnModerationStatus(String id);
}
