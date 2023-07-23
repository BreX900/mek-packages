import 'package:collection/collection.dart';

enum KotlinVisibility { public, protected, private }

class KotlinParameter implements KotlinClassInitializer {
  final List<String> annotations;
  final String name;
  final String type;
  final String? defaultTo;

  const KotlinParameter({
    this.annotations = const [],
    required this.name,
    required this.type,
    this.defaultTo,
  });
}

enum KotlinMethodModifier { override, suspend }

class KotlinMethod extends KotlinTopLevelSpec {
  final KotlinVisibility? visibility;
  final Set<KotlinMethodModifier> modifiers;
  final String name;
  final List<KotlinParameter> parameters;
  final String? returns;
  final bool lambda;
  final String? body;

  const KotlinMethod({
    this.visibility,
    this.modifiers = const {},
    required this.name,
    this.parameters = const [],
    this.returns,
    this.lambda = false,
    this.body,
  });
}

class KotlinInterface extends KotlinTopLevelSpec {
  final KotlinVisibility? visibility;
  final String name;
  final List<String> implements;
  final List<KotlinField> fields;
  final List<KotlinTopLevelSpec> body;

  const KotlinInterface({
    this.visibility,
    required this.name,
    this.implements = const [],
    this.fields = const [],
    this.body = const [],
  });

  bool get isInterface => true;

  bool get hasBody => fields.isNotEmpty || body.isNotEmpty;
}

class KotlinEnum extends KotlinInterface {
  final List<String> values;

  KotlinEnum({
    super.visibility,
    required super.name,
    super.implements,
    required this.values,
    super.fields = const [],
    super.body = const [],
  });

  @override
  bool get isInterface => false;

  @override
  bool get hasBody => super.hasBody || values.isNotEmpty;
}

enum KotlinFieldModifier { var$, val, lateInit }

class KotlinField extends KotlinClassInitializer {
  final KotlinVisibility? visibility;
  final KotlinFieldModifier modifier;
  final String name;
  final String type;
  final String? assignment;

  const KotlinField({
    this.visibility,
    this.modifier = KotlinFieldModifier.val,
    required this.name,
    required this.type,
    this.assignment,
  });
}

enum KotlinClassModifier { abstract, data, companion }

sealed class KotlinClassInitializer {
  const KotlinClassInitializer();
}

class KotlinClass extends KotlinInterface {
  final KotlinClassModifier? modifier;
  final String? extend;
  final List<KotlinClassInitializer> initializers;

  const KotlinClass({
    super.visibility,
    this.modifier,
    required super.name,
    this.extend,
    super.implements = const [],
    this.initializers = const [],
    super.fields = const [],
    super.body = const [],
  });

  @override
  bool get isInterface => false;
}

class KotlinLibrary extends KotlinSpec {
  final String package;
  final List<String> imports;
  final List<KotlinTopLevelSpec> body;

  const KotlinLibrary({
    required this.package,
    this.imports = const [],
    this.body = const [],
  });
}

sealed class KotlinTopLevelSpec extends KotlinSpec {
  const KotlinTopLevelSpec();
}

sealed class KotlinSpec {
  const KotlinSpec();
}

class KotlinEmitter {
  int _indent = 0;

  String get _space => '    ' * _indent;

  Object encode(KotlinSpec spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      KotlinLibrary() => _encodeLibrary(spec),
      KotlinTopLevelSpec() => _encodeTopLevelSpec(spec, isInInterface: false),
    });
    return buffer;
  }

  Object _encodeTopLevelSpec(KotlinTopLevelSpec spec, {required bool isInInterface}) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      KotlinInterface() => _encodeInterface(spec),
      KotlinMethod() => _encodeMethod(spec, isInInterface: isInInterface),
    });
    return buffer;
  }

  Object _encodeLibrary(KotlinLibrary spec) {
    final buffer = StringBuffer();
    buffer.write('package ${spec.package}\n\n');
    buffer.writeAll(spec.imports.map((e) => 'import $e'), '\n');
    if (spec.imports.isNotEmpty) buffer.write('\n\n');
    buffer.writeAll(spec.body.map(encode), '\n\n');
    return buffer;
  }

  Object _encodeVisibility(KotlinVisibility? visibility) =>
      visibility != null ? '${visibility.name} ' : '';

  Object _encodeInitializer(KotlinClassInitializer spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      KotlinField() => _encodeField(spec),
      KotlinParameter() => _encodeParameter(spec),
    });
    return buffer;
  }

  Object _encodeInterface(KotlinInterface spec) {
    final buffer = StringBuffer();
    final title = switch (spec) {
      KotlinClass() => switch (spec.modifier) {
          KotlinClassModifier.abstract => 'abstract class',
          KotlinClassModifier.data => 'data class',
          KotlinClassModifier.companion => 'companion',
          null => 'class',
        },
      KotlinEnum() => 'enum class',
      KotlinInterface() => 'interface',
    };
    buffer.write('$_space${_encodeVisibility(spec.visibility)}$title ${spec.name}');
    if (spec is KotlinClass && spec.initializers.isNotEmpty) {
      buffer.write('(\n');
      _indent += 1;
      buffer.writeAll(spec.initializers.map(_encodeInitializer), ',\n');
      buffer.write(',\n');
      _indent -= 1;
      buffer.write('$_space)');
    }
    final extendAndImplements = [
      if (spec is KotlinClass && spec.extend != null) spec.extend!,
      ...spec.implements,
    ];
    if (extendAndImplements.isNotEmpty) {
      buffer.write(': ');
      buffer.writeAll(extendAndImplements, ', ');
    }

    if (!spec.hasBody) {
      buffer.write('\n');
      return buffer;
    }

    buffer.write(' {');
    if (spec is KotlinEnum) {
      _indent += 1;
      buffer.write('\n$_space');
      buffer.writeAll(spec.values, ', ');
      buffer.write(';\n');
      _indent += -1;
    }
    if (spec.fields.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.fields.map(_encodeField), '\n');
      _indent -= 1;
      buffer.write('\n');
    }
    if (spec.body.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.body.map((e) {
        return _encodeTopLevelSpec(e, isInInterface: spec.isInterface);
      }), '\n\n');
      _indent -= 1;
      buffer.write('\n');
    }
    buffer.write('$_space}');
    return buffer;
  }

  Object _encodeField(KotlinField spec) {
    final visibility = _encodeVisibility(spec.visibility);
    final modifier = switch (spec.modifier) {
      KotlinFieldModifier.var$ => 'var',
      KotlinFieldModifier.val => 'val',
      KotlinFieldModifier.lateInit => 'lateinit var',
    };
    final assignment = spec.assignment != null ? ' = ${spec.assignment}' : '';
    return '$_space$visibility$modifier ${spec.name}: ${spec.type}$assignment';
  }

  Object _encodeMethod(KotlinMethod spec, {required bool isInInterface}) {
    final buffer = StringBuffer();
    buffer.write(_space);
    buffer.write(_encodeVisibility(spec.visibility));
    if (spec.body == null && !isInInterface) buffer.write('abstract ');
    buffer.writeAll(spec.modifiers.sortedBy<num>((e) => e.index).map((e) => '${e.name} '));
    buffer.write('fun ${spec.name}(');
    if (spec.parameters.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.parameters.map(_encodeParameter), ',\n');
      buffer.write(',\n');
      _indent -= 1;
      buffer.write('$_space)');
    } else {
      buffer.write(')');
    }
    if (spec.returns != null) buffer.write(': ${spec.returns}');

    if (spec.body == null) return buffer;
    if (spec.lambda) {
      buffer.write(' = ');
      buffer.write(spec.body);
    } else {
      buffer.write(' {\n');
      _indent += 1;
      buffer.write(spec.body!.split('\n').map((e) => '$_space$e').join('\n'));
      _indent -= 1;
      buffer.write('\n$_space}');
    }
    return buffer;
  }

  Object _encodeParameter(KotlinParameter spec) {
    final defaultTo = spec.defaultTo != null ? ' = ${spec.defaultTo}' : '';
    return '$_space${spec.name}: ${spec.type}$defaultTo';
  }
}
