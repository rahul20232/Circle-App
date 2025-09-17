// lib/screens/Auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Auth/controllers/register_controller.dart';
import 'package:timeleft_clone/screens/Auth/components/register_components.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterController _controller;
  late RegisterComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = RegisterComponents(controller: _controller);
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
            colors: [Colors.green.shade50, Colors.white],
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
                    _components.buildHeader(),
                    SizedBox(height: 32),
                    _components.buildNameInput(),
                    SizedBox(height: 20),
                    _components.buildEmailInput(),
                    SizedBox(height: 20),
                    _components.buildPasswordInput(),
                    SizedBox(height: 32),
                    _components.buildRegisterButton(context),
                    SizedBox(height: 20),
                    _components.buildDivider(),
                    SizedBox(height: 24),
                    _components.buildBackToLoginButton(context),
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
