/// Base class for domain-level failures across MediCare
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// Server or API failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Local database or cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Network or connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.code,
  });
}

/// Authentication or authorization failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}
