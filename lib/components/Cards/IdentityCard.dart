import 'package:flutter/material.dart';

class Identitycard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const Identitycard({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity, // Make it responsive to screen width
          height: 130,
          child: Stack(
            children: <Widget>[
              // Outer border container
              Container(
                width: double.infinity, // Use full width instead of fixed 380
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black,
                ),
              ),

              // Inner content container
              Positioned(
                top: 2,
                left: 2,
                right: 2, // Add right positioning for responsive width
                child: Container(
                  height: 119, // Remove fixed width, let it expand
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: isSelected
                        ? Colors.black
                        : Color.fromRGBO(250, 250, 250, 1),
                  ),
                ),
              ),

              // Check icon for selected state
              if (isSelected) ...[
                Positioned(
                  bottom: 15,
                  height: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              // Text content
              Positioned(
                bottom: isSelected ? -15 : 5,
                left: 0,
                right: 0,
                height: 130,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16), // Add padding to prevent text overflow
                    child: Text(
                      text,
                      textAlign: TextAlign
                          .center, // Changed from left to center for better responsive behavior
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Arial',
                        fontSize: 20,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Handle long text gracefully
                      maxLines: 2, // Allow text to wrap to 2 lines if needed
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
