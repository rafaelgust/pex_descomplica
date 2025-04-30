abstract class CustomerFailure {
  final String message;

  const CustomerFailure(this.message);
}

class CustomerSearchFailure extends CustomerFailure {
  const CustomerSearchFailure(super.message);
}

class RegistrationFailure extends CustomerFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends CustomerFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends CustomerFailure {
  const NetworkFailure(super.message);
}
