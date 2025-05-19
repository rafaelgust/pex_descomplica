abstract class RoleFailure {
  final String message;

  const RoleFailure(this.message);
}

class RoleSearchFailure extends RoleFailure {
  const RoleSearchFailure(super.message);
}

class RegistrationFailure extends RoleFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends RoleFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends RoleFailure {
  const NetworkFailure(super.message);
}
