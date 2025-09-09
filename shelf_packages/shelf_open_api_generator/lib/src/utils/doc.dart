import 'package:build/build.dart';
import 'package:collection/collection.dart';

class Doc {
  static const Doc none = Doc(summary: null, description: null, example: null);

  final String? summary;
  final String? description;
  final String? example;

  String? get summaryAndDescription =>
      summary != null && description != null ? '$summary\n$description' : (summary ?? description);

  const Doc({required this.summary, required this.description, required this.example});

  factory Doc.from(String? doc) {
    if (doc == null) return none;

    final String? summary;
    final String? description;
    final String? example;

    final lines = _clean(doc);

    final lastLine = lines.lastOrNull;
    if (lastLine != null) {
      final examples = RegExp(r'`([^`]+)`').allMatches(lastLine).toList();

      example = examples.singleOrNull?.group(1);
      if (example != null) {
        lines.removeLast(); // TODO: remove side effect
      } else if (examples.isNotEmpty) {
        log.warning('The doc not support many examples!\n$doc');
      }
    } else {
      example = null;
    }

    final divider = lines.elementAtOrNull(1);
    if (divider == null) {
      summary = lines.elementAtOrNull(0);
      description = null;
    } else if (divider.isNotEmpty) {
      summary = null;
      description = lines.join('\n');
    } else {
      summary = lines.elementAt(0);
      description = lines.skip(2).join('\n');
    }

    return Doc(summary: summary, description: description, example: example);
  }

  static String? clean(String? doc) {
    if (doc == null) return null;
    final cleanedDoc = _clean(doc);
    if (cleanedDoc.isEmpty) return null;
    return cleanedDoc.join('\n');
  }

  static List<String> _clean(String doc) {
    final lines = doc.replaceAll('///', '').split('\n').map((e) => e.trim());

    return lines
        .skipWhile((e) => e.isEmpty)
        .toList()
        .reversed
        .skipWhile((e) => e.isEmpty)
        .toList()
        .reversed
        .toList();
  }
}
