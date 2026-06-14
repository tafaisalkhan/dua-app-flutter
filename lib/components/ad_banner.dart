import 'package:flutter/material.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key, required this.position});

  final String position;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D8),
        border: Border.all(color: const Color(0xFFE2BE77)),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        position,
        style: const TextStyle(
          color: Color(0xFF7B5311),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
