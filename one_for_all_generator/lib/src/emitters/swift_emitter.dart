enum SwiftVisibility { public, protected, private }

class SwiftParameter {
  final String? fieldName;
  final String label;
  final String name;
  final String? annotation;
  final String type;

  const SwiftParameter({
    String? label,
    required this.name,
    this.annotation,
    required this.type,
  })  : label = label ?? name,
        fieldName = null;

  SwiftParameter.fromField(
    SwiftField field, {
    String? label,
    String? name,
    this.annotation,
  })  : fieldName = field.name,
        label = label ?? name ?? field.name,
        name = name ?? field.name,
        type = field.type;
}

class SwiftMethod extends SwiftSpec {
  final SwiftVisibility? visibility;
  final String name;
  final List<SwiftParameter> parameters;
  final String? returnType;
  final String? body;

  const SwiftMethod({
    this.visibility,
    required this.name,
    this.parameters = const [],
    this.returnType,
    this.body,
  });
}

class SwiftProtocol extends SwiftSpec {
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

class SwiftField {
  final SwiftVisibility? visibility;
  final SwiftFieldModifier modifier;
  final String name;
  final String type;

  const SwiftField({
    this.visibility,
    this.modifier = SwiftFieldModifier.let,
    required this.name,
    required this.type,
  });

  SwiftParameter toParameter({
    String? label,
    String? name,
    String? annotation,
  }) =>
      SwiftParameter.fromField(
        this,
        label: label,
        name: name,
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

class SwiftLibrary extends SwiftLanguage {
  final List<String> imports;
  final List<SwiftSpec> body;

  const SwiftLibrary({
    required this.imports,
    required this.body,
  });
}

sealed class SwiftSpec extends SwiftLanguage {
  const SwiftSpec();
}

sealed class SwiftLanguage {
  const SwiftLanguage();
}

class SwiftEmitter {
  int _indent = 0;

  String get _space => '    ' * _indent;

  Object encode(SwiftLanguage spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      SwiftLibrary() => _encodeLibrary(spec),
      SwiftSpec() => _encodeSpec(spec),
    });
    return buffer;
  }

  Object _encodeLibrary(SwiftLibrary spec) {
    final buffer = StringBuffer();
    buffer.writeAll(spec.imports.map((e) => 'import $e'), '\n');
    if (spec.imports.isNotEmpty) buffer.write('\n\n');
    buffer.writeAll(spec.body.map(_encodeSpec), '\n');
    return buffer;
  }

  Object _encodeSpec(SwiftSpec spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      SwiftProtocol() => _encodeProtocol(spec),
      SwiftMethod() => _encodeMethod(spec),
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
      buffer.write('${_space}case ');
      buffer.writeAll(spec.values, '\n${_space}case ');
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
    buffer.write('$_space}\n');
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
    return '$_space${_encodeVisibility(spec.visibility)}$modifier ${spec.name}: ${spec.type}';
  }

  Object _encodeMethod(SwiftMethod spec) {
    final buffer = StringBuffer();
    buffer.write(_space);
    buffer.write('${_encodeVisibility(spec.visibility)}func ${spec.name}(');
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
    if (spec.returnType != null) buffer.write(': ${spec.returnType}');

    if (spec.body != null) {
      buffer.write(' {\n');
      _indent += 1;
      buffer.write(spec.body!.split('\n').map((e) => '$_space$e').join('\n'));
      _indent -= 1;
      buffer.write('\n$_space}');
    }
    return buffer;
  }

  Object _encodeParameter(SwiftParameter spec) {
    final annotation = spec.annotation;
    return '$_space${spec.label} ${spec.name}: ${annotation != null ? '@$annotation ' : ''}${spec.type}';
  }
}
