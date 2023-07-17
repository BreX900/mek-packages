import Flutter

class Result<T> {
    private let result: FlutterResult
    private let serializer: (T) -> Any?

    init(
        _ result: @escaping FlutterResult,
        _ serializer: @escaping (T) -> Any?
    ) {
        self.result = result
        self.serializer = serializer
    }

    func success(
        _ data: T
    ) {
        result.success(serializer(data))
    }

    func error(
        _ code: String,
        _ message: String,
        _ details: Any?
    ) {
        result(FlutterError(code: code, message: message, details: details))
    }
}
