abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialise extends AuthEvent {
  const AuthEventInitialise();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthEventRegister({
    required this.email,
    required this.password,
    required this.name,
  });
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogin({required this.email, required this.password});
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({required this.email});
}

class AuthEventNeedsVerification extends AuthEvent {
  const AuthEventNeedsVerification();
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}
class AuthEventSendVerification extends AuthEvent{
  const AuthEventSendVerification();
}