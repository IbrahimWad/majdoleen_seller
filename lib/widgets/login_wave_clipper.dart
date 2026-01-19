import 'package:flutter/material.dart';

class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 90);
    path.quadraticBezierTo(
      size.width * 0.22,
      size.height - 30,
      size.width * 0.55,
      size.height - 60,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height - 95,
      size.width,
      size.height - 55,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
