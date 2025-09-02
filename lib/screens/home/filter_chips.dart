import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: const Center(
        child: Text(
          "Filter Chips (Coming Soon)",
          style: TextStyle(color: subFontColor),
        ),
      ),
    );
  }
}