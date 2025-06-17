abstract final class Docs {
  /// TODO: use max width line for docs
  static Iterable<String> format(Iterable<String> lines) {
    return lines.map((line) => '/// $line');
  }

  static Iterable<String> documentClass({
    String? description,
    Object? example,
  }) sync* {
    if (description != null) yield* description.split('\n');
    if (example != null) yield 'Ex. $example';
  }

  static Iterable<String> documentMethod({
    String? summary,
    String? description,
    Iterable<String> params = const [],
  }) sync* {
    summary = summary?.nullIfBlank;
    description = description?.nullIfBlank;

    if (summary != null) yield* summary.split('\n');
    if (description != null) yield* description.split('\n');
    if (params.isNotEmpty) yield* params;
  }

  // TODO: Implement examples
  static Iterable<String> documentField({
    required String name,
    String? description,
    Object? example,
    Map<String, Object?> examples = const {},
  }) sync* {
    final paragraphTitle = '- [$name] ';

    final lines = <String>[
      ...?description?.nullIfBlank?.split('\n'),
      if (example != null) 'Ex. $example',
    ];
    switch (lines.length) {
      case 0:
        break;
      case 1:
        yield '$paragraphTitle ${lines.single}';
      default:
        yield paragraphTitle;
        yield* lines.map((line) => '  $line');
    }
  }
}

extension on String {
  String? get nullIfBlank => trim().isEmpty ? null : this;
}
