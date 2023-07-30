import Foundation

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
