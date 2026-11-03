import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class SubscribeProfileUseCase {
  const SubscribeProfileUseCase(this._repository);

  final IUserRepository _repository;

  Stream<UserProfile?> call(String userId) => _repository.watchProfile(userId);
}
