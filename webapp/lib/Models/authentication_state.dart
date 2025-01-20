import 'package:weddingform/Models/authentication_type.dart';

class AuthenticationState {
  AuthenticationType authenticationType;
  String username;
  String password;

  AuthenticationState({
    this.authenticationType = AuthenticationType.unauthorized,
    this.username = '',
    this.password = '',
  });
}
