abstract class ProductFailure {
  final String message;

  const ProductFailure(this.message);
}

class ProductSearchFailure extends ProductFailure {
  const ProductSearchFailure(super.message);
}

class RegistrationFailure extends ProductFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends ProductFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends ProductFailure {
  const NetworkFailure(super.message);
}
