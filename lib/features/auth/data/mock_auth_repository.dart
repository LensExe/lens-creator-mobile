import '../../../domain/models/models.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/mock_database.dart';

class MockAuthRepository implements AuthRepository {
  final Map<String, ({User user, String password})> _accounts = {
    'nhiepanhgia@lens.vn': (
      user: MockDatabase.photographerUser,
      password: 'demo1234',
    ),
  };

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw StateError('Email hoặc mật khẩu không đúng');
    }
    return account.user;
  }

  @override
  Future<User> register(
    String name,
    String email,
    String password, {
    required String location,
    required List<String> styles,
  }) async {
    if (location.trim().isEmpty || styles.isEmpty) {
      throw StateError('Vui lòng chọn khu vực và ít nhất một phong cách');
    }
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

  @override
  Future<User> updateProfile(User user) async {
    final currentUser = MockDatabase.currentUser;
    if (currentUser == null || currentUser.id != user.id) {
      throw StateError('Vui lòng đăng nhập bằng tài khoản cần cập nhật');
    }
    final accountEntry = _accounts.entries.firstWhere(
      (entry) => entry.value.user.id == user.id,
      orElse: () => throw StateError('Không tìm thấy tài khoản'),
    );
    _accounts[accountEntry.key] = (
      user: user,
      password: accountEntry.value.password,
    );
    MockDatabase.currentUser = user;
    return user;
  }

  @override
  Future<User> readCurrentProfile() async {
    final user = MockDatabase.currentUser;
    if (user == null) throw StateError('Vui lòng đăng nhập');
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = MockDatabase.currentUser;
    if (currentUser == null) throw StateError('Vui lòng đăng nhập');
    final accountEntry = _accounts.entries.firstWhere(
      (entry) => entry.value.user.id == currentUser.id,
      orElse: () => throw StateError('Không tìm thấy tài khoản'),
    );
    if (accountEntry.value.password != currentPassword) {
      throw StateError('Mật khẩu hiện tại không chính xác');
    }
    if (newPassword.length < 8) {
      throw StateError('Mật khẩu mới cần ít nhất 8 ký tự');
    }
    _accounts[accountEntry.key] = (
      user: accountEntry.value.user,
      password: newPassword,
    );
  }

  @override
  Future<void> logout() async {}
}

final mockAuthRepository = MockAuthRepository();
