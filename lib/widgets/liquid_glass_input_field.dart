import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class LiquidGlassInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final int maxLines;
  final int minLines;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final Color? accentColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const LiquidGlassInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.minLines = 1,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.accentColor,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<LiquidGlassInputField> createState() => _LiquidGlassInputFieldState();
}

class _LiquidGlassInputFieldState extends State<LiquidGlassInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.growthAccent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.surfaceElevated.withOpacity(0.85)
                : const Color(0x0FFFDDBE),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isFocused
                  ? accent.withOpacity(0.65)
                  : const Color(0x1FFFFFFF),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.20),
                      blurRadius: 18,
                      spreadRadius: -2,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.labelText != null) ...[
                Text(
                  widget.labelText!.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: _isFocused ? accent : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                crossAxisAlignment: widget.maxLines > 1
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  if (widget.prefixIcon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.prefixIcon,
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      textInputAction: widget.textInputAction,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      cursorColor: accent,
                      onChanged: widget.onChanged,
                      onSubmitted: (_) => widget.onSubmitted?.call(),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted.withOpacity(0.8),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (widget.suffixIcon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: widget.suffixIcon,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
