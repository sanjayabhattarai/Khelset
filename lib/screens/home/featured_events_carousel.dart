import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class FeaturedEventsCarousel extends StatelessWidget {
  const FeaturedEventsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Center(
        child: Text(
          "Featured Events Carousel (Coming Soon)",
          style: TextStyle(color: subFontColor),
        ),
      ),
    );
  }
}