import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LiquidGlassSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Color accentColor;

  const LiquidGlassSearchBar({
    Key? key,
    required this.onChanged,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<LiquidGlassSearchBar> createState() => _LiquidGlassSearchBarState();
}

class _LiquidGlassSearchBarState extends State<LiquidGlassSearchBar> {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 52.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0x1AFFDDBE),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: _isFocused ? widget.accentColor : const Color(0x1AFFFFFF),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16.0),
              Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search affirmations...',
                    hintStyle: AppTextStyles.searchHint,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
