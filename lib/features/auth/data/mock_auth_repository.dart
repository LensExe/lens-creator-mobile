import '../../../domain/models/models.dart';
import '../../../data/mock_database.dart';

class MockAuthRepository {
  final Map<String, ({User user, String password})> _accounts = {
    'nhiepanhgia@lens.vn': (
      user: MockDatabase.photographerUser,
      password: 'demo1234',
    ),
  };

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw StateError('Email hoặc mật khẩu không đúng');
    }
    return account.user;
  }

  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalized = email.trim().toLowerCase();
    if (_accounts.containsKey(normalized)) {
      throw StateError('Email đã được sử dụng');
    }
    final user = User(
      id: 'creator-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalized,
      role: 'photographer',
    );
    _accounts[normalized] = (user: user, password: password);
    return user;
  }
}

final mockAuthRepository = MockAuthRepository();
