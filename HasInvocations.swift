import XCTest

protocol HasInvocations {
    associatedtype Invocation: Equatable
    
    var invocations: [Invocation] { get set }
}

extension HasInvocations {
    func checkInvocations(_ invocations: [Invocation],
                          file: StaticString = #file,
                          line: UInt = #line) {
        guard self.invocations.count == invocations.count else {
            XCTFail("Invocations mismatch: expected \(invocations) but got \(self.invocations)",
                file: file,
                line: line)
            return
        }
        for (index, invocation) in invocations.enumerated() {
            XCTAssertEqual(self.invocations[index], invocation,
                           file: file,
                           line: line)
        }
    }
    
    mutating func clearInvocations() {
        invocations = []
    }
}
