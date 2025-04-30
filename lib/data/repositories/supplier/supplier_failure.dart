abstract class SupplierFailure {
  final String message;

  const SupplierFailure(this.message);
}

class SupplierSearchFailure extends SupplierFailure {
  const SupplierSearchFailure(super.message);
}

class RegistrationFailure extends SupplierFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends SupplierFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends SupplierFailure {
  const NetworkFailure(super.message);
}
