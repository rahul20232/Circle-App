import 'package:flutter/material.dart';

class NewCard extends StatelessWidget {
  final String date;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;
  final int? availableSpots;
  final String? location;

  const NewCard({
    Key? key,
    required this.date,
    required this.time,
    required this.isSelected,
    required this.onTap,
    this.availableSpots,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate card height based on whether location is provided
    double cardHeight = location != null ? 110 : 90;

    return Container(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity, // Make it responsive to screen width
          height: cardHeight,
          child: Stack(
            children: <Widget>[
              // Background container
              Container(
                width: double.infinity, // Use full width instead of fixed 380
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isSelected ? Colors.black : Colors.transparent,
                ),
              ),

              // Inner container
              Positioned(
                top: 2,
                left: 2,
                right: 2, // Add right positioning for responsive width
                child: Container(
                  height: cardHeight - 11, // Remove fixed width, let it expand
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Color.fromRGBO(250, 250, 250, 1),
                  ),
                ),
              ),

              // Date text
              Positioned(
                top: 20,
                left: 22,
                right: 50, // Add right constraint to prevent overflow
                child: Text(
                  date,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Time text
              Positioned(
                top: 46,
                left: 22,
                right: 50, // Add right constraint to prevent overflow
                child: Text(
                  time,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Inter',
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Location text (if provided)
              if (location != null)
                Positioned(
                  top: 70,
                  left: 22,
                  right: 50, // Add right constraint for responsive width
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        // Use Expanded instead of fixed width Container
                        child: Text(
                          location!,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Inter',
                            fontSize: 12,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                            height: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              // Selection indicator (responsive positioning)
              Positioned(
                top: 32,
                right: 22, // Use right positioning instead of fixed left
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.red.shade400
                        : Color.fromRGBO(250, 250, 250, 1),
                    border: Border.all(
                      color: isSelected
                          ? Colors.red.shade400
                          : Color.fromRGBO(0, 0, 0, 1),
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(15),
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
