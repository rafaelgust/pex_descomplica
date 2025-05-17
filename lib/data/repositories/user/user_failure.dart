abstract class UserFailure {
  final String message;

  const UserFailure(this.message);
}

class UserSearchFailure extends UserFailure {
  const UserSearchFailure(super.message);
}

class RegistrationFailure extends UserFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends UserFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends UserFailure {
  const NetworkFailure(super.message);
}
