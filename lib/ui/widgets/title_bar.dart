import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_colors.dart';

/// Custom title bar widget with window controls and glassmorphism effect
/// 
/// Provides:
/// - Draggable area for window movement
/// - Window control buttons (close, minimize, maximize)
/// - Glassmorphism visual effect
class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: AppDimensions.titleBarHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.separator.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.blurSigmaDefault,
              sigmaY: AppDimensions.blurSigmaDefault,
            ),
            child: Container(
              color: AppColors.glassLight.withOpacity(0.7),
              child: Row(
                children: [
                  // Window control buttons on the left (macOS style)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spacingMedium,
                    ),
                    child: Row(
                      children: [
                        _WindowControlButton(
                          color: const Color(0xFFFF5F57),
                          onPressed: () => windowManager.close(),
                          icon: CupertinoIcons.xmark,
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        _WindowControlButton(
                          color: const Color(0xFFFEBC2E),
                          onPressed: () => windowManager.minimize(),
                          icon: CupertinoIcons.minus,
                        ),
                        const SizedBox(width: AppDimensions.spacingSmall),
                        _WindowControlButton(
                          color: const Color(0xFF28C840),
                          onPressed: () async {
                            if (await windowManager.isMaximized()) {
                              windowManager.unmaximize();
                            } else {
                              windowManager.maximize();
                            }
                          },
                          icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                        ),
                      ],
                    ),
                  ),
                  // Spacer to keep buttons on the left
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual window control button widget
class _WindowControlButton extends StatefulWidget {
  final Color color;
  final VoidCallback onPressed;
  final IconData icon;

  const _WindowControlButton({
    required this.color,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: _isHovered
              ? Icon(
                  widget.icon,
                  size: 8,
                  color: const Color(0xFF000000).withOpacity(0.6),
                )
              : null,
        ),
      ),
    );
  }
}
