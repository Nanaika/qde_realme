abstract class AuthRepository {
  Future login();
  Future logout();
  Future getCurrentUser(String id);
  Future<bool> getOnModerationStatus(String id);
}
