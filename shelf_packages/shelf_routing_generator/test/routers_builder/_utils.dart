import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:shelf_routing_generator/routing_builder.dart';

Future<String?> testRouterBuilder({required String source}) async {
  const package = 'example';
  final writer = InMemoryAssetWriter();

  await testBuilder(
    routingBuilder(BuilderOptions.empty),
    {'$package|example.dart': source},
    reader: await PackageAssetReader.currentIsolate(),
    writer: writer,
  );

  final content = writer.assets[AssetId(package, 'example.routing.g.part')];
  if (content == null) return null;

  return utf8
      .decode(content)
      .replaceAll(RegExp(r'//[^\n]*\n'), '')
      .split('\n')
      .where((e) => e.isNotEmpty)
      .join('\n');
}
