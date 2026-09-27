import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Standardized AVAN app bar widget with Cormorant Garamond typography,
/// frosted liquid glass backing, and customizable leading/trailing slots.
class AvanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isFrosted;
  final double height;
  final Color? backgroundColor;

  const AvanAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.leading,
    this.isFrosted = true,
    this.height = kToolbarHeight,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final content = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                  tooltip: 'Back',
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                )
              : null),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
    );

    if (!isFrosted) return content;

    final bool shouldBlur = !kIsWeb && defaultTargetPlatform != TargetPlatform.android;

    Widget bar = Container(
      decoration: BoxDecoration(
        color: (backgroundColor ?? AppColors.background).withOpacity(shouldBlur ? 0.75 : 0.95),
        border: const Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.8,
          ),
        ),
      ),
      child: content,
    );

    if (shouldBlur) {
      bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: bar,
        ),
      );
    }

    return RepaintBoundary(child: bar);
  }
}
