import 'package:flutter/material.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/Models/authentication_type.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _validatePassword() async {
    String password = _passwordController.text.trim();
    final response = await http.post(
      Uri.parse('http://localhost:3000/validate-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['type'] == 0) {
        widget.onAuthenticationChanged(AuthenticationState(
            authenticationType: AuthenticationType.attendingCoffee,
            username: data['username'],
            password: data['password']));
      } else if (data['type'] == 1) {
        widget.onAuthenticationChanged(AuthenticationState(
            authenticationType: AuthenticationType.attendingFestivities,
            username: data['username'],
            password: data['password']));
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
