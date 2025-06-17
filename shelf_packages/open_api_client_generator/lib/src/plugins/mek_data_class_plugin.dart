import 'package:code_builder/code_builder.dart';
import 'package:open_api_client_generator/src/plugins/plugin.dart';
import 'package:open_api_specification/open_api_spec.dart';
import 'package:recase/recase.dart';

class MekDataClassPlugin with Plugin {
  const MekDataClassPlugin();

  @override
  Class onDataClass(SchemaOpenApi schema, Class spec) {
    return spec.rebuild((b) => b
      ..annotations.add(const CodeExpression(Code('DataClass()')))
      ..mixins.add(Reference('_\$${spec.name.pascalCase}')));
  }

  @override
  Library onLibrary(OpenApi openApi, Library spec) {
    return spec.rebuild(
        (b) => b..directives.add(Directive.import('package:mek_data_class/mek_data_class.dart')));
  }
}
