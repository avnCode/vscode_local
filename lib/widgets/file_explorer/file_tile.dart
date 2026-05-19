import 'package:flutter/material.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class FileTile extends StatelessWidget {
  final FileNode node;
  final int depth;
  final bool isExpanded;
  final bool isActive;
  final VSCodeColors colors;
  final VoidCallback onTap;

  const FileTile({
    super.key,
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? colors.accent.withValues(alpha: 0.2) : Colors.transparent,
        padding: EdgeInsets.only(
          left: 12.0 + depth * 14.0,
          top: 3,
          bottom: 3,
          right: 8,
        ),
        child: Row(
          children: [
            _leadingIcon(),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(
                  color: isActive ? colors.accent : colors.onSurface,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingIcon() {
    if (node.isDirectory) {
      return Icon(
        isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
        size: 16,
        color: colors.muted,
      );
    }
    return _fileTypeIcon();
  }

  Widget _fileTypeIcon() {
    final color = _iconColor();
    final icon = _iconData();
    return Icon(icon, size: 14, color: color);
  }

  Color _iconColor() {
    switch (node.extension) {
      case 'py':
        return const Color(0xFF4B8BBE);
      case 'md':
      case 'markdown':
        return const Color(0xFF519ABA);
      case 'json':
      case 'yaml':
      case 'yml':
        return const Color(0xFFCE9178);
      case 'ipynb':
        return const Color(0xFFE8A020);
      case 'pdf':
        return const Color(0xFFE74C3C);
      case 'dart':
        return const Color(0xFF54C5F8);
      case 'js':
      case 'ts':
        return const Color(0xFFF7DF1E);
      case 'html':
        return const Color(0xFFE34C26);
      case 'css':
      case 'scss':
        return const Color(0xFF563D7C);
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
        return const Color(0xFF27AE60);
      default:
        return colors.muted;
    }
  }

  IconData _iconData() {
    switch (node.extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      case 'bmp':
        return Icons.image_outlined;
      case 'md':
      case 'markdown':
        return Icons.article_outlined;
      case 'ipynb':
        return Icons.menu_book_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}
