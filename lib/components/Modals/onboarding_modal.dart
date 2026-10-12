import 'package:flutter/material.dart';

class OnboardingModal extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback? onClose;

  const OnboardingModal({
    Key? key,
    required this.onContinue,
    required this.onRestart,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          if (onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Column(
              children: [
                // Title
                Text(
                  'Continue your onboarding',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Description
                Text(
                  'It looks like you\'ve already started the onboarding process. Would you like to continue from where you left off, or restart from the beginning?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    // Restart button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRestart,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Restart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16),

                    // Continue button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
