import 'package:flutter/material.dart';

void showSuccessOverlay(BuildContext context, String message) {
  _showOverlay(context, message, Colors.green, Icons.check_circle_outline);
}

void showErrorOverlay(BuildContext context, String message) {
  _showOverlay(context, message, const Color(0xFFE53935), Icons.error_outline);
}

void _showOverlay(BuildContext context, String message, Color color, IconData icon) {
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
  Future.delayed(const Duration(seconds: 2), entry.remove);
}
