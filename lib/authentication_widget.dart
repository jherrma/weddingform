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

  void _validatePassword() {
    String password = _passwordController.text.trim();
    if (password == 'secret1') {
      widget.onAuthenticationChanged(AuthenticationState.attendingCoffee);
      setState(() {
        showError = false;
      });
    } else if (password == 'secret2') {
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
          decoration: const InputDecoration(labelText: 'Enter password'),
          onFieldSubmitted: (_) => _validatePassword(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _validatePassword,
          child: const Text('Submit'),
        ),
        if (showError)
          const Text(
            'Incorrect password',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
