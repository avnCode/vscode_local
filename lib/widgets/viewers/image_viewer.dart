import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class ImageViewer extends StatelessWidget {
  final FileNode file;
  const ImageViewer({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 8.0,
      child: Center(
        child: Image.file(
          File(file.path),
          errorBuilder: (_, error, __) => Center(
            child: Text(
              'Cannot display image: $error',
              style: TextStyle(color: colors.muted),
            ),
          ),
        ),
      ),
    );
  }
}
