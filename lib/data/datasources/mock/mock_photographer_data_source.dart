import '../../../domain/models/models.dart';
import '../../mock_database.dart';

class MockPhotographerDataSource {
  static const _delay = Duration(milliseconds: 300);

  Future<Photographer> create(Photographer photographer) async {
    await Future.delayed(_delay);
    if (MockDatabase.photographers.any((item) => item.id == photographer.id)) {
      throw StateError('Hồ sơ nhiếp ảnh gia đã tồn tại');
    }
    MockDatabase.photographers.add(photographer);
    return photographer;
  }

  Future<Photographer> update(Photographer photographer) async {
    await Future.delayed(_delay);
    final index = MockDatabase.photographers.indexWhere(
      (item) => item.id == photographer.id,
    );
    if (index < 0) throw StateError('Không tìm thấy hồ sơ nhiếp ảnh gia');
    MockDatabase.photographers[index] = photographer;
    return photographer;
  }
}
