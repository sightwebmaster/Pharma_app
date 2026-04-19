import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 24,
    this.backgroundColor = AppColors.primaryGreen,
    this.textColor = Colors.white,
  });

  final UserModel? user;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final imageData = _extractBase64(user?.photoBase64);
    if (imageData != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(imageData)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        user?.initials ?? '?',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  String? _extractBase64(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    if (raw.contains(',')) {
      return raw.split(',').last;
    }
    return raw;
  }
}
