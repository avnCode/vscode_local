import 'dart:convert';

class NotebookModel {
  final String nbformat;
  final List<NotebookCell> cells;

  NotebookModel({required this.nbformat, required this.cells});

  factory NotebookModel.fromJson(Map<String, dynamic> json) {
    final rawCells = (json['cells'] as List?) ?? [];
    return NotebookModel(
      nbformat: '${json['nbformat'] ?? 4}.${json['nbformat_minor'] ?? 0}',
      cells: rawCells.map((c) => NotebookCell.fromJson(c)).toList(),
    );
  }

  static NotebookModel parse(String content) {
    final json = jsonDecode(content) as Map<String, dynamic>;
    return NotebookModel.fromJson(json);
  }
}

class NotebookCell {
  final CellType cellType;
  final String source;
  final List<NotebookOutput> outputs;
  final int? executionCount;

  NotebookCell({
    required this.cellType,
    required this.source,
    required this.outputs,
    this.executionCount,
  });

  factory NotebookCell.fromJson(Map<String, dynamic> json) {
    final rawSource = json['source'];
    final source = rawSource is List
        ? rawSource.join()
        : (rawSource as String? ?? '');

    final rawOutputs = (json['outputs'] as List?) ?? [];
    final outputs = rawOutputs.map((o) => NotebookOutput.fromJson(o)).toList();

    return NotebookCell(
      cellType: _parseCellType(json['cell_type'] as String? ?? ''),
      source: source,
      outputs: outputs,
      executionCount: json['execution_count'] as int?,
    );
  }

  static CellType _parseCellType(String type) {
    switch (type) {
      case 'markdown':
        return CellType.markdown;
      case 'raw':
        return CellType.raw;
      default:
        return CellType.code;
    }
  }
}

enum CellType { code, markdown, raw }

class NotebookOutput {
  final OutputType outputType;

  // text/plain, text/html outputs
  final String? text;

  // image/png, image/jpeg — base64
  final String? imageBase64;
  final String? imageMimeType;

  // error
  final String? errorName;
  final String? errorValue;
  final List<String>? traceback;

  NotebookOutput({
    required this.outputType,
    this.text,
    this.imageBase64,
    this.imageMimeType,
    this.errorName,
    this.errorValue,
    this.traceback,
  });

  factory NotebookOutput.fromJson(Map<String, dynamic> json) {
    final type = json['output_type'] as String? ?? '';

    if (type == 'error') {
      return NotebookOutput(
        outputType: OutputType.error,
        errorName: json['ename'] as String?,
        errorValue: json['evalue'] as String?,
        traceback: ((json['traceback'] as List?) ?? [])
            .map((l) => _stripAnsi(l.toString()))
            .toList(),
      );
    }

    final data = json['data'] as Map<String, dynamic>?;
    final textRaw = json['text'] ?? data?['text/plain'];

    String? textOutput;
    if (textRaw is List) {
      textOutput = textRaw.join();
    } else if (textRaw is String) {
      textOutput = textRaw;
    }

    // Prefer image outputs
    String? imageBase64;
    String? imageMimeType;
    if (data != null) {
      for (final mime in ['image/png', 'image/jpeg', 'image/gif']) {
        if (data.containsKey(mime)) {
          final raw = data[mime];
          imageBase64 = raw is List ? raw.join() : raw as String?;
          imageMimeType = mime;
          break;
        }
      }
    }

    return NotebookOutput(
      outputType: imageBase64 != null ? OutputType.image : OutputType.text,
      text: textOutput,
      imageBase64: imageBase64,
      imageMimeType: imageMimeType,
    );
  }

  static String _stripAnsi(String input) {
    return input.replaceAll(RegExp(r'\x1B\[[0-9;]*[mGKH]'), '');
  }
}

enum OutputType { text, image, error }
