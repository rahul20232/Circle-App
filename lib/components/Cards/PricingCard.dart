import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const PriceCard({
    Key? key,
    required this.title,
    required this.duration,
    required this.price,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth =
        screenWidth - 64; // Subtract padding (16*2) and spacing (16*2)
    final cardWidth =
        (availableWidth / 3).clamp(100.0, 122.0); // Minimum 100, maximum 122
    final cardHeight =
        cardWidth * 1.27; // Maintain aspect ratio (155/122 ≈ 1.27)
    final topSectionHeight = cardHeight * 0.16; // 25/155 ≈ 0.16

    // Scale font sizes proportionally
    final titleFontSize = (cardWidth / 122 * 14).clamp(12.0, 14.0);
    final contentFontSize = (cardWidth / 122 * 18).clamp(14.0, 18.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          children: [
            // Background containers (scaled)
            Positioned(
              top: topSectionHeight,
              left: 0,
              right: 0,
              child: Container(
                height: cardHeight - topSectionHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: isSelected ? Colors.black : Colors.transparent,
                ),
              ),
            ),
            Positioned(
              top: topSectionHeight,
              left: 0.5,
              right: 0.5,
              child: Container(
                height: cardHeight - topSectionHeight - 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13),
                  ),
                  color: Color.fromRGBO(250, 250, 250, 1),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: topSectionHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                  color: isSelected ? Colors.red.shade400 : Color(0xFFBCB6B6),
                ),
              ),
            ),

            // Title text
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topSectionHeight,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Inter',
                    fontSize: titleFontSize,
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Duration text - centered in middle section
            Positioned(
              top: topSectionHeight + (cardHeight - topSectionHeight) * 0.25,
              left: 4,
              right: 4,
              height: (cardHeight - topSectionHeight) * 0.25,
              child: Center(
                child: Text(
                  duration,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontSize: contentFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Price text - centered in bottom section
            Positioned(
              bottom: (cardHeight - topSectionHeight) * 0.15,
              left: 4,
              right: 4,
              height: (cardHeight - topSectionHeight) * 0.25,
              child: Center(
                child: Text(
                  price,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontSize: contentFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
