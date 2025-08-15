import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:shelf_routing_generator/routing_builder.dart';

Future<String?> testRoutingBuilder({required String source}) async {
  const package = 'example';
  final readerWriter = TestReaderWriter();

  await testBuilder(
    routingBuilder(BuilderOptions.empty),
    {'$package|example.dart': source},
    readerWriter: readerWriter,
    // reader: await PackageAssetReader.currentIsolate(),
  );

  final content = await readerWriter.readAsBytes(AssetId(package, 'example.routing.g.part'));

  return utf8
      .decode(content)
      .replaceAll(RegExp(r'//[^\n]*\n'), '')
      .split('\n')
      .where((e) => e.isNotEmpty)
      .join('\n');
}
