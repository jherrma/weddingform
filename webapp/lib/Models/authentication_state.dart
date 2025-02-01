import 'package:weddingform/Models/authentication_type.dart';

class AuthenticationState {
  AuthenticationType authenticationType;
  String username;
  String password;
  String emailCoffee;
  String emailRide;
  String emailContribution;

  AuthenticationState({
    this.authenticationType = AuthenticationType.unauthorized,
    this.username = '',
    this.password = '',
    this.emailCoffee = '',
    this.emailRide = '',
    this.emailContribution = '',
  });
}
