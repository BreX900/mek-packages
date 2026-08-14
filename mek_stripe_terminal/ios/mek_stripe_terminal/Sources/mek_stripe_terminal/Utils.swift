import Foundation

func createApiException(_ code: TerminalExceptionCodeApi, _ message: String? = nil) -> TerminalExceptionApi {
    return TerminalExceptionApi(
        apiError: nil,
        code: code,
        message: message ?? "",
        paymentIntent: nil,
        stackTrace: nil
    )
}
