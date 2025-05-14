abstract class DashboardFailure {
  final String message;

  const DashboardFailure(this.message);
}

class DashboardSearchFailure extends DashboardFailure {
  const DashboardSearchFailure(super.message);
}

class RegistrationFailure extends DashboardFailure {
  const RegistrationFailure(super.message);
}

class DeleteFailure extends DashboardFailure {
  const DeleteFailure(super.message);
}
