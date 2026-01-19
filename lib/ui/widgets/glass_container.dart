import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_dimensions.dart';

/// A reusable container widget that applies glassmorphism effect
/// 
/// Uses BackdropFilter to create a translucent, blurred background
/// with configurable border radius and blur intensity.
/// 
/// Requirements: 2.1, 2.2
class GlassContainer extends StatelessWidget {
  /// The widget to display inside the glass container
  final Widget child;
  
  /// Border radius for the container corners
  final double borderRadius;
  
  /// Blur intensity (sigma value for Gaussian blur)
  final double blurSigma;
  
  /// Optional padding inside the container
  final EdgeInsetsGeometry? padding;
  
  /// Optional width constraint
  final double? width;
  
  /// Optional height constraint
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = AppDimensions.borderRadiusMedium,
    this.blurSigma = AppDimensions.blurSigmaDefault,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: CupertinoColors.separator.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
