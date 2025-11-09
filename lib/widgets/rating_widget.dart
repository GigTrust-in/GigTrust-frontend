import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final bool editable;
  final Function(double)? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.editable,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap( 
      spacing: 2, 
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: editable
              ? () => onRatingChanged?.call(starIndex.toDouble())
              : null,
          child: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 18, 
          ),
        );
      }),
    );
  }
}