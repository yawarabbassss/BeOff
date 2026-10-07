import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.black;
        break;
      case ButtonVariant.secondary:
        bg = Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDarkSecondary
            : AppColors.surfaceLightSecondary;
        fg = Theme.of(context).brightness == Brightness.dark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = Theme.of(context).brightness == Brightness.dark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight;
        border = BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        );
        break;
      case ButtonVariant.danger:
        bg = AppColors.danger;
        fg = Colors.white;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
