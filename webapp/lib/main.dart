import 'package:flutter/material.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/Models/authentication_type.dart';
import 'package:weddingform/authentication_widget.dart';
import 'package:weddingform/form_widget.dart';

Future main() async {
  runApp(const WeddingFormApp());
}

class WeddingFormApp extends StatelessWidget {
  const WeddingFormApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hochzeit von Sarah und Noah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeddingFormHomePage(title: 'Hochzeit von Sarah und Noah'),
    );
  }
}

class WeddingFormHomePage extends StatefulWidget {
  const WeddingFormHomePage({super.key, required this.title});

  final String title;

  @override
  State<WeddingFormHomePage> createState() => _WeddingFormHomePageState();
}

class _WeddingFormHomePageState extends State<WeddingFormHomePage> {
  AuthenticationState _authenticationState = AuthenticationState(
      authenticationType: AuthenticationType.unauthorized,
      username: '',
      password: '');

  void _authenticationChanged(AuthenticationState authenticationState) {
    setState(() {
      _authenticationState = authenticationState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _authenticationState.authenticationType ==
                      AuthenticationType.unauthorized
                  ? AuthenticationWidget(
                      onAuthenticationChanged: _authenticationChanged,
                    )
                  : FormWidget(authenticationState: _authenticationState)),
        ));
  }
}
