import '../models/models.dart';

abstract interface class PhotographerRepository {
  Future<Photographer> createPhotographer(Photographer photographer);

  Future<Photographer> updatePhotographer(Photographer photographer);
}
