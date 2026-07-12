abstract class BonusesRepository {
  Future update(Map<String, String> bonuses);
  Future<Map<String, String>> get();
}
