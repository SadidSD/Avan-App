import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Ultra-premium Liquid Glass search bar with dynamic lighting,
/// soft refractive glow on focus, animated icons, and a one-tap clear button.
class LiquidGlassSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Color accentColor;
  final String hintText;
  final TextEditingController? controller;

  const LiquidGlassSearchBar({
    Key? key,
    required this.onChanged,
    required this.accentColor,
    this.hintText = 'Search affirmations & playlists...',
    this.controller,
  }) : super(key: key);

  @override
  State<LiquidGlassSearchBar> createState() => _LiquidGlassSearchBarState();
}

class _LiquidGlassSearchBarState extends State<LiquidGlassSearchBar>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: 54.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.0),
        boxShadow: [
          // Soft ambient mocha shadow
          BoxShadow(
            color: const Color(0x40000000),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          // Dynamic accent glow when active
          if (_isFocused)
            BoxShadow(
              color: widget.accentColor.withOpacity(0.24),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isFocused
                    ? [
                        widget.accentColor.withOpacity(0.12),
                        const Color(0x18FFDDBE),
                      ]
                    : const [
                        Color(0x22FFDDBE),
                        Color(0x0CFFDDBE),
                      ],
              ),
              borderRadius: BorderRadius.circular(27.0),
              border: Border.all(
                color: _isFocused
                    ? widget.accentColor.withOpacity(0.65)
                    : AppColors.borderBright,
                width: _isFocused ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Animated Search Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isFocused
                        ? widget.accentColor.withOpacity(0.18)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isFocused
                        ? widget.accentColor
                        : AppColors.textSecondary,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 10.0),

                // Search Input Field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    cursorColor: widget.accentColor,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Clear button (appears smoothly when typing)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _hasText
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            widget.onChanged('');
                          },
                          child: Container(
                            key: const ValueKey('clear_btn'),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('empty_spacer'),
                          width: 0,
                          height: 0,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
