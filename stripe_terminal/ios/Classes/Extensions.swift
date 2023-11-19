import Foundation

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
    var nsNumberValue: NSNumber { get {
        return NSNumber(value: self)
    } }
}

extension UInt {
    var intValue: Int { get {
        return Int(self)
    } }
}
