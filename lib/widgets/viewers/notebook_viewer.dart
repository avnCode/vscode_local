import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../models/file_node.dart';
import '../../models/notebook_model.dart';
import '../../theme/app_theme.dart';

class NotebookViewer extends StatefulWidget {
  final FileNode file;
  const NotebookViewer({super.key, required this.file});

  @override
  State<NotebookViewer> createState() => _NotebookViewerState();
}

class _NotebookViewerState extends State<NotebookViewer> {
  late Future<NotebookModel> _notebook;

  @override
  void initState() {
    super.initState();
    _notebook = _load();
  }

  @override
  void didUpdateWidget(NotebookViewer old) {
    super.didUpdateWidget(old);
    if (old.file.path != widget.file.path) {
      _notebook = _load();
    }
  }

  Future<NotebookModel> _load() async {
    final raw = await widget.file.readAsString();
    return NotebookModel.parse(raw);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;

    return FutureBuilder<NotebookModel>(
      future: _notebook,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              'Failed to parse notebook: ${snap.error}',
              style: TextStyle(color: colors.muted),
            ),
          );
        }
        final notebook = snap.data!;
        return Scrollbar(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notebook.cells.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _CellWidget(cell: notebook.cells[i], colors: colors),
          ),
        );
      },
    );
  }
}

class _CellWidget extends StatelessWidget {
  final NotebookCell cell;
  final VSCodeColors colors;

  const _CellWidget({required this.cell, required this.colors});

  @override
  Widget build(BuildContext context) {
    switch (cell.cellType) {
      case CellType.markdown:
        return _MarkdownCell(cell: cell, colors: colors);
      case CellType.code:
        return _CodeCell(cell: cell, colors: colors);
      case CellType.raw:
        return _RawCell(cell: cell, colors: colors);
    }
  }
}

class _MarkdownCell extends StatelessWidget {
  final NotebookCell cell;
  final VSCodeColors colors;
  const _MarkdownCell({required this.cell, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MarkdownBody(
        data: cell.source,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(color: colors.onSurface, fontSize: 14, height: 1.5),
          h1: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          h2: TextStyle(color: colors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          h3: TextStyle(color: colors.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
          code: const TextStyle(
            color: Color(0xFFCE9178),
            backgroundColor: Color(0xFF2D2D2D),
            fontFamily: 'monospace',
            fontSize: 12,
          ),
          codeblockDecoration: const BoxDecoration(
            color: Color(0xFF2D2D2D),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          codeblockPadding: const EdgeInsets.all(10),
          strong: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold),
          em: TextStyle(color: colors.onSurface, fontStyle: FontStyle.italic),
          a: TextStyle(color: colors.accent),
          listBullet: TextStyle(color: colors.onSurface),
        ),
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  final NotebookCell cell;
  final VSCodeColors colors;
  const _CodeCell({required this.cell, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cell header with execution count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            border: Border.all(color: colors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Text(
                cell.executionCount != null
                    ? 'In [${cell.executionCount}]:'
                    : 'In [ ]:',
                style: const TextStyle(
                  color: Color(0xFF4B8BBE),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        // Code block
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.divider, width: 0.5),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              cell.source,
              language: 'python',
              theme: vs2015Theme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ),
        // Outputs
        if (cell.outputs.isNotEmpty) ...[
          const SizedBox(height: 2),
          ...cell.outputs.map((o) => _OutputWidget(output: o, colors: colors)),
        ],
      ],
    );
  }
}

class _RawCell extends StatelessWidget {
  final NotebookCell cell;
  final VSCodeColors colors;
  const _RawCell({required this.cell, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.sidebar,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.divider, width: 0.5),
      ),
      child: SelectableText(
        cell.source,
        style: TextStyle(
          color: colors.muted,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),
    );
  }
}

class _OutputWidget extends StatelessWidget {
  final NotebookOutput output;
  final VSCodeColors colors;
  const _OutputWidget({required this.output, required this.colors});

  @override
  Widget build(BuildContext context) {
    switch (output.outputType) {
      case OutputType.image:
        return _buildImage();
      case OutputType.error:
        return _buildError();
      case OutputType.text:
        return _buildText();
    }
  }

  Widget _buildText() {
    if (output.text == null || output.text!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: const Color(0xFF3C3C3C), width: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: SelectableText(
        output.text!,
        style: const TextStyle(
          color: Color(0xFFD4D4D4),
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (output.imageBase64 == null) return const SizedBox.shrink();
    try {
      final bytes = base64Decode(output.imageBase64!.replaceAll('\n', ''));
      return Container(
        padding: const EdgeInsets.all(8),
        color: const Color(0xFF141414),
        child: Image.memory(
          Uint8List.fromList(bytes),
          fit: BoxFit.contain,
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildError() {
    final lines = <String>[
      if (output.errorName != null) '${output.errorName}: ${output.errorValue ?? ''}',
      ...?output.traceback,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF1A0000),
      child: SelectableText(
        lines.join('\n'),
        style: const TextStyle(
          color: Color(0xFFFF6B6B),
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
