abstract class AuthFailure {
  final String message;

  const AuthFailure(this.message);
}

class AuthenticationFailure extends AuthFailure {
  const AuthenticationFailure(super.message);
}

class RegistrationFailure extends AuthFailure {
  const RegistrationFailure(super.message);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends AuthFailure {
  const ValidationFailure(super.message);
}
