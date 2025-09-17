// lib/screens/Auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Auth/controllers/login_controller.dart';
import 'package:timeleft_clone/screens/Auth/components/login_components.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;
  late LoginComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = LoginComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _components.buildHeader(context),
                    SizedBox(height: 32),
                    _components.buildEmailInput(),
                    SizedBox(height: 20),
                    _components.buildPasswordInput(),
                    SizedBox(height: 32),
                    _components.buildLoginButton(context),
                    SizedBox(height: 20),
                    _components.buildDivider(),
                    SizedBox(height: 20),
                    _components.buildRegisterButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
