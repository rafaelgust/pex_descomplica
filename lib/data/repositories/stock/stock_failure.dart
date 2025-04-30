abstract class StockFailure {
  final String message;

  const StockFailure(this.message);
}

class StockSearchFailure extends StockFailure {
  const StockSearchFailure(super.message);
}

class RegistrationFailure extends StockFailure {
  const RegistrationFailure(super.message);
}

class UpdationFailure extends StockFailure {
  const UpdationFailure(super.message);
}

class NetworkFailure extends StockFailure {
  const NetworkFailure(super.message);
}
