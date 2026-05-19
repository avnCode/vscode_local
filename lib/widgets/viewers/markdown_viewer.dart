import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class MarkdownViewer extends StatefulWidget {
  final FileNode file;
  const MarkdownViewer({super.key, required this.file});

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = widget.file.readAsString();
  }

  @override
  void didUpdateWidget(MarkdownViewer old) {
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

        return Markdown(
          data: snap.data ?? '',
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: colors.onSurface, fontSize: 14, height: 1.6),
            h1: TextStyle(
              color: colors.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            h2: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            h3: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            h4: TextStyle(color: colors.onSurface, fontSize: 15),
            h5: TextStyle(color: colors.onSurface, fontSize: 14),
            h6: TextStyle(color: colors.onSurface, fontSize: 13),
            code: const TextStyle(
              color: Color(0xFFCE9178),
              backgroundColor: Color(0xFF2D2D2D),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            codeblockDecoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            codeblockPadding: const EdgeInsets.all(12),
            blockquoteDecoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFF007ACC), width: 3),
              ),
            ),
            blockquotePadding: const EdgeInsets.only(left: 12),
            blockquote: TextStyle(color: colors.muted, fontSize: 14),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.divider),
              ),
            ),
            listBullet: TextStyle(color: colors.onSurface),
            strong: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            em: TextStyle(
              color: colors.onSurface,
              fontStyle: FontStyle.italic,
            ),
            a: TextStyle(color: colors.accent),
            tableBody: TextStyle(color: colors.onSurface, fontSize: 13),
            tableHead: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tableBorder: TableBorder.all(color: colors.divider, width: 1),
          ),
          padding: const EdgeInsets.all(20),
        );
      },
    );
  }
}
