import 'package:collection/collection.dart';

sealed class KotlinSpec {
  const KotlinSpec();
}

class KotlinLibrary extends KotlinSpec {
  final String package;
  final List<String> imports;
  final List<KotlinClass> classes;

  const KotlinLibrary({
    required this.package,
    this.imports = const [],
    this.classes = const [],
  });
}

enum KotlinClassModifier { abstract, data, companion }

class KotlinEnum extends KotlinClass {
  final List<String> values;

  KotlinEnum({
    required super.name,
    required this.values,
    super.classes = const [],
  });

  @override
  bool get hasBody => super.hasBody || values.isNotEmpty;
}

sealed class KotlinClassInitializer extends KotlinSpec {
  const KotlinClassInitializer();
}

class KotlinClass extends KotlinSpec {
  final KotlinClassModifier? modifier;
  final String name;
  final List<String> superTypes;
  final List<KotlinClassInitializer> initializers;
  final List<KotlinField> fields;
  final List<KotlinMethod> methods;
  final List<KotlinClass> classes;

  const KotlinClass({
    this.modifier,
    required this.name,
    this.superTypes = const [],
    this.initializers = const [],
    this.fields = const [],
    this.methods = const [],
    this.classes = const [],
  });

  bool get hasBody => fields.isNotEmpty || methods.isNotEmpty || classes.isNotEmpty;
}

enum KotlinFieldVisibility { public, protected, private }

enum KotlinFieldModifier { var$, val, lateInit }

class KotlinField extends KotlinClassInitializer {
  final KotlinFieldVisibility? visibility;
  final KotlinFieldModifier modifier;
  final String name;
  final String type;

  const KotlinField({
    this.visibility,
    this.modifier = KotlinFieldModifier.val,
    required this.name,
    required this.type,
  });
}

enum KotlinMethodModifier { override, suspend }

class KotlinMethod extends KotlinSpec {
  final Set<KotlinMethodModifier> modifiers;
  final String name;
  final List<KotlinParameter> parameters;
  final String? returnType;
  final String? body;

  const KotlinMethod({
    this.modifiers = const {},
    required this.name,
    this.parameters = const [],
    this.returnType,
    this.body,
  });
}

class KotlinParameter extends KotlinSpec implements KotlinClassInitializer {
  final List<String> annotations;
  final String name;
  final String type;

  const KotlinParameter({
    this.annotations = const [],
    required this.name,
    required this.type,
  });
}

class KotlinEmitter {
  int _indent = 0;

  String get _space => '    ' * _indent;

  Object encode(KotlinSpec spec) {
    final buffer = StringBuffer();
    buffer.write(switch (spec) {
      KotlinLibrary() => _encodeLibrary(spec),
      KotlinClass() => _encodeClass(spec),
      KotlinField() => _encodeField(spec),
      KotlinMethod() => _encodeMethod(spec),
      KotlinParameter() => _encodeParameter(spec),
    });
    return buffer;
  }

  Object _encodeLibrary(KotlinLibrary spec) {
    final buffer = StringBuffer();
    buffer.write('package ${spec.package}\n\n');
    buffer.writeAll(spec.imports.map((e) => 'import $e'), '\n');
    if (spec.imports.isNotEmpty) buffer.write('\n\n');
    buffer.writeAll(spec.classes.map(_encodeClass), '\n');
    return buffer;
  }

  Object _encodeClass(KotlinClass spec) {
    final buffer = StringBuffer(_space);
    if (spec is! KotlinEnum) {
      buffer.write(switch (spec.modifier) {
        KotlinClassModifier.abstract => 'abstract class ',
        KotlinClassModifier.data => 'data class ',
        KotlinClassModifier.companion => 'companion ',
        null => 'class ',
      });
    } else {
      buffer.write('enum class ');
    }
    buffer.write(spec.name);
    if (spec.initializers.isNotEmpty) {
      buffer.write(' (\n');
      _indent += 1;
      buffer.writeAll(spec.initializers.map(encode), ',\n');
      _indent -= 1;
      buffer.write('\n)');
    }
    if (spec.superTypes.isNotEmpty) {
      buffer.write(': ');
      buffer.writeAll(spec.superTypes, ', ');
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
    if (spec.methods.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.methods.map(_encodeMethod), '\n\n');
      _indent -= 1;
      buffer.write('\n');
    }
    if (spec.classes.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.classes.map(_encodeClass), '\n\n');
      _indent -= 1;
      buffer.write('\n');
    }
    buffer.write('$_space}\n');
    return buffer;
  }

  Object _encodeField(KotlinField spec) {
    final visibility = spec.visibility != null ? '${spec.visibility!.name} ' : '';
    final modifier = switch (spec.modifier) {
      KotlinFieldModifier.var$ => 'var ',
      KotlinFieldModifier.val => 'val ',
      KotlinFieldModifier.lateInit => 'lateinit var ',
    };
    return '$_space$visibility$modifier${spec.name}: ${spec.type}';
  }

  Object _encodeMethod(KotlinMethod spec) {
    final buffer = StringBuffer();
    buffer.write(_space);
    if (spec.body == null) buffer.write('abstract ');
    buffer.writeAll(spec.modifiers.sortedBy<num>((e) => e.index).map((e) => '${e.name} '));
    buffer.write('fun ${spec.name}(');
    if (spec.parameters.isNotEmpty) {
      buffer.write('\n');
      _indent += 1;
      buffer.writeAll(spec.parameters.map((e) => '${_encodeParameter(e)},\n'));
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

  Object _encodeParameter(KotlinParameter spec) {
    return '$_space${spec.name}: ${spec.type}';
  }
}
