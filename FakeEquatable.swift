import Foundation

protocol FakeEquatable: Equatable {
    var fakeValue: String { get }
}

extension FakeEquatable {
    var fakeValue: String {
        return String(describing: self)
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.fakeValue == rhs.fakeValue
    }
}

struct FakeEquatableWrapper<T> {
    let element: T
    
    init(_ element: T) {
        self.element = element
    }
}

extension FakeEquatableWrapper: FakeEquatable {}
