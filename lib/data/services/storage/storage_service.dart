abstract class StorageService {
  // Métodos para manipulação de armazenamento padrão (cookies/local storage)
  Future<void> setItem(String key, String value, {int? daysToExpire});
  Future<String?> getItem(String key);
  Future<void> deleteItem(String key);
  Future<void> clear();

  // Métodos para manipulação de tokens via secure storage
  Future<void> setTokens({required String? access, required String? refresh});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> deleteTokens();
}
