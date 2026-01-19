import 'package:flutter/cupertino.dart';
import '../../data/models/note.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import 'glass_container.dart';
import 'package:intl/intl.dart';

/// A card widget that displays a note preview with glassmorphism styling
/// 
/// Shows the first 100 characters of note content and the last modified timestamp.
/// Tapping the card opens the note editor with a subtle scale animation.
/// 
/// Requirements: 5.1, 5.5, 5.6, 7.4, 7.5
class NoteCard extends StatefulWidget {
  /// The note to display
  final Note note;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _isPressed = false;

  /// Format the timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(
          milliseconds: AppDimensions.animationDurationShort,
        ),
        curve: Curves.easeInOutCubic,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Note preview text
              Text(
                widget.note.preview.isEmpty ? 'Empty note' : widget.note.preview,
                style: AppTextStyles.body.copyWith(
                  color: widget.note.preview.isEmpty 
                      ? AppColors.textTertiary 
                      : AppColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              // Last modified timestamp
              Text(
                _formatTimestamp(widget.note.lastModifiedAt),
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
