/// Specifies the array format (a single parameter with multiple parameter
/// or multiple parameters with the same name).
/// and the separator for array items.
enum QueryParameterFormat {
  /// Comma-separated values.
  /// e.g. (foo,bar,baz)
  // csv,
  form,

  /// Space-separated values.
  /// e.g. (foo bar baz)
  // ssv,
  spaceDelimited,

  /// Pipe-separated values.
  /// e.g. (foo|bar|baz)
  // pipes,
  pipeDelimited,

  /// Multiple parameter instances rather than multiple values.
  /// e.g. (foo=value&foo=another_value)
  // multi,
  formExpanded,
}

/// Specifies the array format (a single parameter with multiple parameter
/// or multiple parameters with the same name).
/// and the separator for array items.
enum HeaderFormat {
  /// Comma-separated values.
  /// e.g. (foo,bar,baz)
  // csv,
  simple,
}
