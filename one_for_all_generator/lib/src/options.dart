import 'package:one_for_all_generator/one_for_all_generator.dart';

class OneForAllOptions {
  final String apiFile;
  final List<String> extraApiFiles;
  final String? packageName;
  final String hostClassSuffix;
  final List<ApiPlatformCodec> codecs;

  const OneForAllOptions({
    required this.apiFile,
    this.extraApiFiles = const [],
    this.packageName,
    this.hostClassSuffix = '',
    this.codecs = const [],
  });

  String channelName(String channel, [String? event]) {
    var name = channel;
    if (packageName != null) name = '$packageName#$name';
    if (event != null) name = '$name#$event';
    return name;
  }
}

class DartOptions {
  final int pageWidth;

  const DartOptions({
    this.pageWidth = 80,
  });
}

class KotlinOptions {
  final String outputFile;
  final String package;

  const KotlinOptions({
    required this.outputFile,
    required this.package,
  });
}

class SwiftOptions {
  final String outputFile;

  const SwiftOptions({
    required this.outputFile,
  });
}
