import Foundation

func createApiException(_ code: TerminalExceptionCodeApi, _ message: String? = nil) -> TerminalExceptionApi {
    return TerminalExceptionApi(
        code: code,
        message: message ?? "",
        stackTrace: nil,
        paymentIntent: nil,
        apiError: nil
    )
}
