import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class CodeViewer extends StatefulWidget {
  final FileNode file;
  const CodeViewer({super.key, required this.file});

  @override
  State<CodeViewer> createState() => _CodeViewerState();
}

class _CodeViewerState extends State<CodeViewer> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = widget.file.readAsString();
  }

  @override
  void didUpdateWidget(CodeViewer old) {
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
        final code = snap.data ?? '';
        final lang = FileTypeHelper.highlightLanguage(widget.file.extension);

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                code,
                language: lang,
                theme: vs2015Theme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
