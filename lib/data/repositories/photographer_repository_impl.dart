import '../../domain/models/models.dart';
import '../../domain/repositories/photographer_repository.dart';
import '../datasources/mock/mock_photographer_data_source.dart';

class PhotographerRepositoryImpl implements PhotographerRepository {
  const PhotographerRepositoryImpl(this.dataSource);

  final MockPhotographerDataSource dataSource;

  @override
  Future<Photographer> createPhotographer(Photographer photographer) =>
      dataSource.create(photographer);

  @override
  Future<Photographer> updatePhotographer(Photographer photographer) =>
      dataSource.update(photographer);
}
