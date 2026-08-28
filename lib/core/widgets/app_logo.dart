import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double fontSize;
  final double iconSize;

  const AppLogo({super.key, this.fontSize = 22, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Ad',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Icon(
          Icons.bolt_rounded,
          color: const Color(0xFFFFD700), // สายฟ้าสีทอง (Gold)
          size: iconSize,
        ),
        Text(
          'Nest',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
