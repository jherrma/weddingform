import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/authentication_widget.dart';
import 'package:weddingform/form_widget.dart';

Future main() async {
  await dotenv.load(isOptional: true, fileName: 'dotenv');
  runApp(const WeddingFormApp());
}

class WeddingFormApp extends StatelessWidget {
  const WeddingFormApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeddingFormHomePage(title: 'Wedding Form'),
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
  AuthenticationState authenticationEnum = AuthenticationState.unauthorized;

  void _authenticationChanged(AuthenticationState authenticationState) {
    setState(() {
      authenticationEnum = authenticationState;
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
              child: authenticationEnum == AuthenticationState.unauthorized
                  ? AuthenticationWidget(
                      onAuthenticationChanged: _authenticationChanged,
                    )
                  : FormWidget(authenticationState: authenticationEnum)),
        ));
  }
}
