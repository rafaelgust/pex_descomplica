abstract class CategoryFailure {
  final String message;

  const CategoryFailure(this.message);
}

class CategorySearchFailure extends CategoryFailure {
  const CategorySearchFailure(super.message);
}

class RegistrationFailure extends CategoryFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends CategoryFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends CategoryFailure {
  const NetworkFailure(super.message);
}
