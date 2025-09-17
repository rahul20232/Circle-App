// lib/screens/Profile/EditProfile/identity_screen.dart
import 'package:flutter/material.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/controllers/identity_controller.dart';
import 'package:timeleft_clone/screens/Profile/EditProfile/components/identity_components.dart';

class IdentityScreen extends StatefulWidget {
  final String title; // AppBar title
  final String question; // Question text
  final String initialValue; // Current value

  const IdentityScreen({
    Key? key,
    required this.title,
    required this.question,
    required this.initialValue,
  }) : super(key: key);

  @override
  _IdentityScreenState createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  late IdentityController _controller;
  late IdentityComponents _components;

  @override
  void initState() {
    super.initState();
    _controller = IdentityController(
      initialValue: widget.initialValue,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _components = IdentityComponents(controller: _controller);
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
        title: Text(
          widget.title,
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _components.buildQuestionText(widget.question),
            const SizedBox(height: 20),
            _components.buildOptionsList(context, widget.question),
          ],
        ),
      ),
    );
  }
}
