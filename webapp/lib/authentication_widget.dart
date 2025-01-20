import 'package:flutter/material.dart';
import 'package:weddingform/Models/authentication_state.dart';

class AuthenticationWidget extends StatefulWidget {
  final Function(AuthenticationState) onAuthenticationChanged;

  const AuthenticationWidget(
      {super.key, required this.onAuthenticationChanged});

  @override
  AuthenticationWidgetState createState() => AuthenticationWidgetState();
}

class AuthenticationWidgetState extends State<AuthenticationWidget> {
  final TextEditingController _passwordController = TextEditingController();
  bool showError = false;
  bool showDefaultPasswordError = false;

  static const String secretDefaultValue = 'default';

  String secretCoffee = const String.fromEnvironment('SECRET_COFFEE',
      defaultValue: secretDefaultValue);
  String secretFestivities = const String.fromEnvironment('SECRET_FESTIVITIES',
      defaultValue: secretDefaultValue);

  @override
  void initState() {
    super.initState();
    secretCoffee = "coffee";
    secretFestivities = "fest";
  }

  void _validatePassword() {
    String password = _passwordController.text.trim();
    if (password == secretCoffee) {
      widget.onAuthenticationChanged(AuthenticationState.attendingCoffee);
      setState(() {
        showError = false;
      });
    } else if (password == secretFestivities) {
      widget.onAuthenticationChanged(AuthenticationState.attendingFestivities);
      setState(() {
        showError = false;
      });
    } else {
      widget.onAuthenticationChanged(AuthenticationState.unauthorized);
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Passwort'),
          onFieldSubmitted: (_) => _validatePassword(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _validatePassword,
          child: const Text('Abschicken'),
        ),
        if (showError)
          const Text(
            'Falsches Passwort',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
