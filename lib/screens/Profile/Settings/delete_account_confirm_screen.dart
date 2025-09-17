// lib/screens/Profile/Settings/delete_account_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/Settings/controllers/delete_account_controller.dart';
import 'package:timeleft_clone/screens/Profile/Settings/components/delete_account_components.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late DeleteAccountController _controller;
  late DeleteAccountComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = DeleteAccountController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = DeleteAccountComponents(controller: _controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF1DE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF1DE),
        elevation: 0,
        title: const Text(
          "Delete Account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _components.buildWarningSection(),
                    const SizedBox(height: 30),
                    _components.buildPasswordField(),
                    const SizedBox(height: 20),
                    _components.buildConfirmationField(),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 30
                          : 100,
                    ),
                  ],
                ),
              ),
            ),
            _components.buildDeleteButton(context),
          ],
        ),
      ),
    );
  }
}
