import '../models/models.dart';

/// Authentication boundary used by the Creator app.
///
/// The mock implementation can be replaced by an API-backed repository
/// without coupling the login screen to a specific transport.
abstract interface class AuthRepository {
  Future<User> login(String email, String password);

  Future<User> register(String name, String email, String password);
}
