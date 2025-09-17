// lib/components/star_rating.dart
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int>? onRatingChanged;
  final bool allowHalfRating;

  const StarRating({
    Key? key,
    this.rating = 0,
    this.maxRating = 5,
    this.size = 25,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
    this.allowHalfRating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: size,
            color: index < rating ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onRatingChanged;

  const InteractiveStarRating({
    Key? key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 30,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _InteractiveStarRatingState createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  void _onStarTapped(int rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () => _onStarTapped(index + 1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              index < _currentRating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: index < _currentRating
                  ? widget.activeColor
                  : widget.inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
