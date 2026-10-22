import Foundation
import os

func createPigeonError(_ code: String?, _ message: String?, _ details: Any? = nil) -> PigeonError {
    return PigeonError(code: "mek_stripe_terminal\(code ?? "")", message: message, details: details)
}

func createUnsupportedOperatingSystem(_ version: String) -> PigeonError {
    return createPigeonError(".unsupoported.operating_system_version", "Available on ios >=\(version)");
}

func handleResult<R>(_ completion: @escaping (Result<R, any Error>) -> Void, callback: @escaping () async throws -> R) {
    Task {
        do {
            let result = try await callback();
            completion(.success(result))
        } catch let error as NSError {
            completion(.failure(error.toPlatformError()))
        }
    }
}

func handleError<R>(_ completion: @escaping (Result<R, any Error>) -> Void, callback: () throws -> Void) {
    do {
        try callback();
    } catch let error as NSError {
        completion(.failure(error.toPlatformError()))
    }
}


extension Optional {
    func apply(_ callback: (_ this: Wrapped) -> Any?) {
        if let this = self { callback(this) }
    }
}

extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        return contains(where: { entry in entry.key == key })
    }
}

extension Dictionary where Value: Equatable {
    func getKey(_ value: Value) -> Key? {
        return self.first(where: { k, v in v == value})?.key
    }
}

extension Int {
    func toInt64() -> Int64 {
        return Int64(self)
    }
}
extension UInt {
    func toInt64() -> Int64 {
        return Int64(self)
    }
    func toNsNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}
extension Int64 {
    func toNsNumber() -> NSNumber {
        return NSNumber(value: self)
    }
    func toUInt() -> UInt {
        return UInt(self)
    }
    func toInt() -> Int {
        return Int(self)
    }
}
extension NSNumber {
    func toInt64() -> Int64 {
        return Int64(truncating: self)
    }
}

extension Date {
    func toMillisecondsSinceEpoch() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

extension PigeonEventSink {
    func addError(_ error: PigeonError) {
        self.error(code: error.code, message: error.message, details: error.details)
    }
}

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "mek_stripe_terminal")

func logUnexpectedResultError(_ result: Result<Void, PigeonError>) {
    switch result {
    case .failure(let error):
        print("[mek_stripe_terminal] \(error.localizedDescription)")
        logger.error("[mek_stripe_terminal] \(error.localizedDescription)")
    case .success():
        // nothing, is ok
        break
    }
}
