import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
