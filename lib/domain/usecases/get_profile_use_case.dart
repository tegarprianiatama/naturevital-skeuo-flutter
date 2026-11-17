import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final IUserRepository _repository;

  Future<UserProfile?> call(String userId) => _repository.fetchProfile(userId);
}
