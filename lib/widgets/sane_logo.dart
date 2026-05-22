import 'package:flutter/material.dart';

/// Logo oficial de la app. Usa el asset en assets/images/sane_logo.png.
class SaneLogo extends StatelessWidget {
  final double width;

  const SaneLogo({super.key, this.width = 180});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/sane_logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}
