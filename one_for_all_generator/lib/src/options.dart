class OneForAllOptions {
  final String apiFile;
  final String hostClassSuffix;

  const OneForAllOptions({
    required this.apiFile,
    this.hostClassSuffix = '',
  });
}

class DartOptions {
  const DartOptions();
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
