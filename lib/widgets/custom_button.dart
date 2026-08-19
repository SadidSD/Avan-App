import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool hasIcon;
  final IconData icon;
  final Color? backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final String variant; // 'primary', 'secondary', 'ghost'

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.hasIcon = true,
    this.icon = Icons.arrow_forward_ios_rounded,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.width = double.infinity,
    this.height = 56.0,
    this.variant = 'primary',
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04, // scale down to 0.96
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;

    final isPrimary = widget.variant == 'primary';
    final isSecondary = widget.variant == 'secondary';

    BoxDecoration decoration;
    Color currentTextColor = widget.textColor;

    if (isPrimary) {
      if (widget.backgroundColor != null) {
        decoration = BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor!.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      } else {
        decoration = BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x403D2C1E),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
        );
      }
    } else if (isSecondary) {
      currentTextColor = AppColors.textPrimary;
      decoration = BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F3D2C1E),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      );
    } else {
      currentTextColor = AppColors.textPrimary;
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28.0),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: decoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: currentTextColor,
                ),
              ),
              if (widget.hasIcon) ...[
                const SizedBox(width: 8),
                Icon(widget.icon, size: 14, color: currentTextColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
