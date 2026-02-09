import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';

class MoodButton extends StatefulWidget {
  final bool isHappy;
  final VoidCallback onTap;
  final bool isSelected;

  const MoodButton({
    super.key,
    required this.isHappy,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<MoodButton> createState() => _MoodButtonState();
}

class _MoodButtonState extends State<MoodButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isHappy 
        ? AppTheme.happyGradient 
        : AppTheme.sadGradient;
    
    final emoji = widget.isHappy ? '😊' : '😢';
    final label = widget.isHappy ? 'VUI' : 'BUỒN';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        width: 140,
        height: 160,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.95 : 1.0,
          _isPressed ? 0.95 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: widget.isSelected || _isPressed
              ? [
                  BoxShadow(
                    color: (widget.isHappy ? AppTheme.happy : AppTheme.sad)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
          border: widget.isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji with animation
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
