import 'package:flutter/material.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class TextViewer extends StatefulWidget {
  final FileNode file;
  const TextViewer({super.key, required this.file});

  @override
  State<TextViewer> createState() => _TextViewerState();
}

class _TextViewerState extends State<TextViewer> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = widget.file.readAsString();
  }

  @override
  void didUpdateWidget(TextViewer old) {
    super.didUpdateWidget(old);
    if (old.file.path != widget.file.path) {
      _content = widget.file.readAsString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;

    return FutureBuilder<String>(
      future: _content,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              'Error reading file: ${snap.error}',
              style: TextStyle(color: colors.muted),
            ),
          );
        }
        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snap.data ?? '',
              style: TextStyle(
                color: colors.onSurface,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        );
      },
    );
  }
}
