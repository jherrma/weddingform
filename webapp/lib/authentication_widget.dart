import 'package:flutter/material.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/Models/authentication_type.dart';
import 'dart:convert';

import 'package:weddingform/Services/http_service.dart';

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

  void _validatePassword() async {
    String password = _passwordController.text.trim();
    try {
      var response = await HttpService.validatePassword(password);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 0) {
          widget.onAuthenticationChanged(AuthenticationState(
              authenticationType: AuthenticationType.attendingCoffee,
              username: data['username'],
              password: data['password'],
              emailCoffee: data['emailCoffee'],
              emailRide: data['emailRide'],
              emailContribution: data['emailContribution']));
        } else if (data['type'] == 1) {
          widget.onAuthenticationChanged(AuthenticationState(
              authenticationType: AuthenticationType.attendingFestivities,
              username: data['username'],
              password: data['password'],
              emailCoffee: data['emailCoffee'],
              emailRide: data['emailRide'],
              emailContribution: data['emailContribution']));
        }
        setState(() {
          showError = false;
        });
      } else {
        widget.onAuthenticationChanged(AuthenticationState(
            authenticationType: AuthenticationType.unauthorized,
            username: '',
            password: ''));
        setState(() {
          showError = true;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
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
      ),
    );
  }
}
