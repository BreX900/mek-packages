import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/code_utils/reference_utils.dart';

class UnionsRegistry {
  final _groupNumbers = <int>{};

  UnionsRegistry();

  Reference buildType(List<Reference> types) {
    if (types.isEmpty) return References.never;
    if (types.singleOrNull case final type?) return type;

    _groupNumbers.add(types.length);
    return References.ref(name(types.length), types: types);
  }

  Iterable<Spec> buildClasses() sync* {
    for (final groupNumber in _groupNumbers) {
      final types = [
        for (var valueNumber = 1; valueNumber <= groupNumber; valueNumber++)
          Reference('T$valueNumber'),
      ];

      yield Class(
        (b) => b
          ..sealed = true
          ..name = name(groupNumber)
          ..types.addAll(types)
          ..constructors.addAll([
            Constructor(
              (b) => b
                ..constant = true
                ..name = '_',
            ),
            for (var valueNumber = 1; valueNumber <= groupNumber; valueNumber++)
              Constructor(
                (b) => b
                  ..constant = true
                  ..factory = true
                  ..name = '\$$valueNumber'
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b
                        ..type = Reference('T$valueNumber')
                        ..name = 'value',
                    ),
                  )
                  ..redirect = Reference(
                    '${name(groupNumber, value: valueNumber, types: types)}._',
                  ),
              ),
          ])
          ..methods.add(
            Method(
              (b) => b
                ..returns = References.jsonValue
                ..name = 'toJson',
            ),
          ),
      );

      for (var valueNumber = 1; valueNumber <= groupNumber; valueNumber++) {
        yield Class(
          (b) => b
            ..modifier = .final$
            ..name = name(groupNumber, value: valueNumber)
            ..types.addAll(types)
            ..extend = References.ref(name(groupNumber), types: types)
            ..constructors.add(
              Constructor(
                (b) => b
                  ..constant = true
                  ..name = '_'
                  ..requiredParameters.add(
                    Parameter(
                      (b) => b
                        ..toThis = true
                        ..name = 'value',
                    ),
                  )
                  ..initializers.add(const Code('super._()')),
              ),
            )
            ..fields.add(
              Field(
                (b) => b
                  ..modifier = .final$
                  ..type = Reference('T$valueNumber')
                  ..name = 'value',
              ),
            )
            ..methods.add(
              Method(
                (b) => b
                  ..annotations.add(const CodeExpression(Code('override')))
                  ..returns = References.jsonValue
                  ..name = 'toJson'
                  ..lambda = true
                  ..body = const Code('value'),
              ),
            ),
        );
      }
    }
  }

  String name(int group, {int? value, List<Reference>? types}) {
    var text = 'Union$group';
    if (value != null) text += '_$value';
    if (types != null) text += '<${types.map((e) => e.symbol!).join(', ')}>';
    return text;
  }
}
