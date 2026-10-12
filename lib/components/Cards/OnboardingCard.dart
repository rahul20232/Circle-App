// lib/screens/Onboarding/middle_screen.dart
import 'package:flutter/material.dart';

// Custom StatsOnboardingCard for the statistics display
class StatsOnboardingCard extends StatelessWidget {
  const StatsOnboardingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      child: Stack(
        children: <Widget>[
          // Outer border container
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
            ),
          ),
          // Inner content container
          Positioned(
            top: 2,
            left: 2,
            right: 2,
            child: Container(
              height: 239,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: Color.fromRGBO(250, 250, 250, 1),
              ),
            ),
          ),
          // Content layout
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top sparkle
                  Text(
                    '♦',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Large percentage - MUCH bigger
                  Text(
                    '96%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      height: 0.8,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Description text - much smaller
                  Text(
                    'The percentage of our dinner groups that rate themselves as compatible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom sparkle
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 60),
                      child: Text(
                        '♦',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
