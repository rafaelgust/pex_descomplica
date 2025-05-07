abstract class InvoiceFailure {
  final String message;

  const InvoiceFailure(this.message);
}

class InvoiceSearchFailure extends InvoiceFailure {
  const InvoiceSearchFailure(super.message);
}

class RegistrationFailure extends InvoiceFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends InvoiceFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends InvoiceFailure {
  const NetworkFailure(super.message);
}
