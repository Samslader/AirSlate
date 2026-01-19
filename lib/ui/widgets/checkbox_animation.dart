import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// An animated circular checkbox widget with smooth fill animation
/// 
/// Provides a smooth transition between checked and unchecked states
/// using AnimatedContainer for the fill effect.
/// 
/// Requirements: 4.4, 7.1
class CheckboxAnimation extends StatelessWidget {
  /// Whether the checkbox is currently checked
  final bool isChecked;
  
  /// Callback when the checkbox is tapped
  final VoidCallback? onTap;
  
  /// Size of the checkbox (diameter)
  final double size;

  const CheckboxAnimation({
    super.key,
    required this.isChecked,
    this.onTap,
    this.size = AppDimensions.checkboxSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppDimensions.animationDurationMedium),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked 
              ? AppColors.primary 
              : CupertinoColors.systemBackground,
          border: Border.all(
            color: isChecked 
                ? AppColors.primary 
                : CupertinoColors.separator,
            width: 2,
          ),
        ),
        child: isChecked
            ? Icon(
                CupertinoIcons.check_mark,
                size: size * 0.6,
                color: CupertinoColors.white,
              )
            : null,
      ),
    );
  }
}
