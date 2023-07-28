import 'package:one_for_all_generator/src/emitters/string_buffer_extensions.dart';

enum SwiftVisibility { public, protected, private }

class SwiftParameter {
  final String? fieldName;
  final String? label;
  final String name;
  final String? annotation;
  final String type;
  final String? defaultTo;

  const SwiftParameter({
    this.label,
    required this.name,
    this.annotation,
    required this.type,
    this.defaultTo,
  }) : fieldName = null;

  SwiftParameter.fromField(
    SwiftField field, {
    String? label,
    String? name,
    this.annotation,
    this.defaultTo,
  })  : fieldName = field.name,
        label = label ?? name ?? field.name,
        name = name ?? field.name,
        type = field.type;
}

enum SwiftMethodModifier { static, override }

class SwiftMethod extends SwiftTopLevelSpec {
  final SwiftVisibility? visibility;
  final SwiftMethodModifier? modifier;
  final bool async;
  final bool throws;
  final String name;
  final List<SwiftParameter> parameters;
  final bool lambda;
  final String? returns;
  final String? body;

  const SwiftMethod({
    this.visibility,
    this.modifier,
    this.async = false,
    this.throws = false,
    required this.name,
    this.parameters = const [],
    this.lambda = false,
    this.returns,
    this.body,
  });
}

class SwiftProtocol extends SwiftTopLevelSpec {
  final SwiftVisibility? visibility;
  final String name;
  final List<String> implements;
  final List<SwiftField> fields;
  final List<SwiftMethod> methods;

  const SwiftProtocol({
    this.visibility,
    required this.name,
    this.implements = const [],
    this.fields = const [],
    this.methods = const [],
  });
}

class SwiftStruct extends SwiftProtocol {
  const SwiftStruct({
    super.visibility,
    required super.name,
    super.implements = const [],
    super.fields = const [],
    super.methods = const [],
  });
}

class SwiftEnum extends SwiftProtocol {
  final List<String> values;

  const SwiftEnum({
    super.visibility,
    required super.name,
    super.implements = const [],
    required this.values,
    super.fields = const [],
    super.methods = const [],
  });
}

enum SwiftFieldModifier { var$, let }

class SwiftField extends SwiftTopLevelSpec {
  final SwiftVisibility? visibility;
  final SwiftFieldModifier modifier;
  final String name;
  final String type;
  final String? assignment;

  const SwiftField({
    this.visibility,
    this.modifier = SwiftFieldModifier.let,
    required this.name,
    required this.type,
    this.assignment,
  });

  SwiftParameter toInitParameter({
    String? label,
    String? name,
    String? annotation,
    String? defaultTo,
  }) =>
      SwiftParameter.fromField(
        this,
        label: label,
        name: name,
        annotation: annotation,
        defaultTo: defaultTo,
      );

  SwiftParameter toParameter({
    String? label,
    String? name,
    String? annotation,
  }) =>
      SwiftParameter(
        type: type,
        label: label,
        name: name ?? this.name,
        annotation: annotation,
      );
}

class SwiftInit {
  final List<SwiftParameter> parameters;
  final String? body;

  const SwiftInit({
    required this.parameters,
    this.body,
  });
}

class SwiftClass extends SwiftProtocol {
  final String? extend;
  final SwiftInit? init;

  const SwiftClass({
    super.visibility,
    required super.name,
    this.extend,
    super.implements = const [],
    super.fields = const [],
    this.init,
    super.methods = const [],
  });
}

class SwiftLibrary extends SwiftSpec {
  final List<String> comments;
  final List<String> imports;
  final List<SwiftTopLevelSpec> body;

  const SwiftLibrary({
    this.comments = const [],
    this.imports = const [],
    this.body = const [],
  });
}

sealed class SwiftTopLevelSpec extends SwiftSpec {
  const SwiftTopLevelSpec();
}

sealed class SwiftSpec {
  const SwiftSpec();
}

class SwiftEmitter {
  int _indent = 0;

  String get _space => '    ' * _indent;

  Object encode(SwiftSpec spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      SwiftLibrary() => _encodeLibrary(spec),
      SwiftTopLevelSpec() => _encodeTopLevelSpec(spec),
    });
    return buffer;
  }

  Object _encodeLibrary(SwiftLibrary spec) {
    final buffer = StringBuffer();
    if (spec.comments.isNotEmpty) {
      buffer.writeAllWith('// ', spec.comments, '\n');
      buffer.write('\n\n');
    }
    if (spec.imports.isNotEmpty) {
      buffer.writeAllWith('import ', spec.imports, '\n');
      buffer.write('\n\n');
    }
    if (spec.body.isNotEmpty) {
      buffer.writeAll(spec.body.map(_encodeTopLevelSpec), '\n\n');
      buffer.write('\n');
    }
    return buffer;
  }

  Object _encodeTopLevelSpec(SwiftTopLevelSpec spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      SwiftProtocol() => _encodeProtocol(spec),
      SwiftMethod() => _encodeMethod(spec),
      SwiftField() => _encodeField(spec),
    });
    return buffer;
  }

  Object _encodeVisibility(SwiftVisibility? visibility) =>
      visibility != null ? '${visibility.name} ' : '';

  Object _encodeProtocol(SwiftProtocol spec) {
    final buffer = StringBuffer();

    final title = switch (spec) {
      SwiftClass() => 'class',
      SwiftEnum() => 'enum',
      SwiftStruct() => 'struct',
      SwiftProtocol() => 'protocol',
    };
    buffer.write('$_space${_encodeVisibility(spec.visibility)}$title ${spec.name}');

    final extendAndImplements = [
      if (spec is SwiftClass && spec.extend != null) spec.extend!,
      ...spec.implements,
    ];
    if (extendAndImplements.isNotEmpty) {
      buffer.write(': ');
      buffer.writeAll(extendAndImplements, ', ');
    }

    buffer.write(' {');
    if (spec is SwiftEnum) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAllWith('${_space}case ', spec.values, '\n');
      _indent += -1;
      buffer.write('\n');
    }

    if (spec.fields.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.fields.map(_encodeField), '\n');
      _indent -= 1;
      buffer.write('\n');
    }
    if (spec is SwiftClass) {
      final initSpec = spec.init;
      if (initSpec != null) {
        buffer.write('\n');
        _indent += 1;
        buffer.write(_encodeInit(initSpec));
        _indent -= 1;
        buffer.write('\n');
      }
    }
    if (spec.methods.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.methods.map(_encodeMethod), '\n\n');
      _indent -= 1;
      buffer.write('\n');
    }
    buffer.write('$_space}');
    return buffer;
  }

  Object _encodeInit(SwiftInit spec) {
    final buffer = StringBuffer();
    buffer.write('${_space}init(');
    if (spec.parameters.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.parameters.map(_encodeParameter), ',\n');
      _indent -= 1;
      buffer.write('\n');
    }
    buffer.write('$_space) {\n');
    _indent += 1;
    buffer.write(_space);
    final lines = spec.parameters
        .where((e) => e.fieldName != null)
        .map((e) => 'self.${e.fieldName} = ${e.name}')
        .followedBy(spec.body?.split('\n') ?? const []);
    buffer.writeAll(lines, '\n$_space');
    _indent -= 1;
    buffer.write('\n$_space}');
    return buffer;
  }

  Object _encodeField(SwiftField spec) {
    final modifier = switch (spec.modifier) {
      SwiftFieldModifier.var$ => 'var',
      SwiftFieldModifier.let => 'let',
    };
    final assignment = spec.assignment != null ? ' = ${spec.assignment}' : '';
    return '$_space${_encodeVisibility(spec.visibility)}$modifier ${spec.name}: ${spec.type}$assignment';
  }

  Object _encodeMethod(SwiftMethod spec) {
    final buffer = StringBuffer();
    buffer.write(_space);
    if (spec.visibility != null) buffer.write(_encodeVisibility(spec.visibility!));
    if (spec.modifier != null) buffer.write('${spec.modifier!.name} ');
    buffer.write('func ${spec.name}(');
    if (spec.parameters.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.parameters.map(_encodeParameter), ',\n');
      buffer.write('\n');
      _indent -= 1;
      buffer.write('$_space)');
    } else {
      buffer.write(')');
    }
    if (spec.async) buffer.write(' async');
    if (spec.throws) buffer.write(' throws');
    if (spec.returns != null) buffer.write(' -> ${spec.returns}');

    if (spec.body == null) return buffer;
    if (spec.lambda) {
      buffer.write(' { ');
      buffer.write(spec.body!);
      buffer.write(' }');
    } else {
      buffer.write(' {\n');
      _indent += 1;
      buffer.write(spec.body!.split('\n').map((e) => '$_space$e').join('\n'));
      _indent -= 1;
      buffer.write('\n$_space}');
    }
    return buffer;
  }

  Object _encodeParameter(SwiftParameter spec) {
    final annotation = spec.annotation != null ? '@${spec.annotation} ' : '';
    final label = spec.label != null ? '${spec.label} ' : '';
    final defaultTo = spec.defaultTo != null ? ' = ${spec.defaultTo}' : '';
    return '$_space$label${spec.name}: $annotation${spec.type}$defaultTo';
  }
}
