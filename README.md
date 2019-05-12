# FakeEquatable
Simple helpers for unit testing in Swift

## Installation
Just add both [FakeEquatable.swift](FakeEquatable.swift) and  [HasInvocations.swift](HasInvocations.swift) to your project's test target

## Use cases 
* [Mock and verify](#mock-and-verify)
* [Assert equal for non equatable value types](equitability) (**CAUTION:  not for use with reference types (classes)**)

## Examples
### Mock and verify
Let's say one needs to mock and verify something similar to

```swift
struct Thing {
    let value: Int
    let message: String
}

protocol SomeOutput {
    func didSomething()
    func didReceive(_ thing: Thing)
    func didFail(_ error: Error)
}
```
with a following usage:
```swift
final class Service {
    enum FetchError: Error {
        case unknown
    }

    let output: SomeOutput

    init(_ output: SomeOutput) {
        self.output = output
    }

    func doSomething() {
        output.didSomething()
    }

    func fetchFromDB() {
        output.didFail(FetchError.unknown)
    }

    func fetchFromNetwork() {
        let result = Thing(value: 42, message: "Answer")
        output.didReceive(result)
    }

    func fetchAndDoSomething() {
        let result = Thing(value: 42, message: "Answer")
        output.didReceive(result)
        output.didSomething()
    }
}

```
In order to do so 
1. Create a mock class that corresponds to `SomeOutput` and `HasInvocations`:

```swift
final class MockSomeOutput: SomeOutput, HasInvocations {
    enum Invocation: FakeEquatable {
        case didSomething
        case didReceive(Thing)
        case didFail(Error)
    }
    var invocations: [Invocation] = []

    func didSomething() {
        invocations.append(.didSomething)
    }

    func didReceive(_ thing: Thing) {
        invocations.append(.didReceive(thing))
        }

    func didFail(_ error: Error) {
        invocations.append(.didFail(error))
        }
}
```

2. Use previously created mock in unit tests:

```swift
final class ServiceTests: XCTestCase {
    var output: MockSomeOutput!
    var service: Service!

    override func setUp() {
        super.setUp()

        output = MockSomeOutput()
        service = Service(output)
    }

    override func tearDown() {
        service = nil
        output = nil

        super.tearDown()
    }

    func testDoSomething() {
        // when
        service.doSomething()

        // then
        output.checkInvocations([.didSomething])
    }

    func testFetchFromDB() {
        // given
        let expectedError = Service.FetchError.unknown

        // when
        service.fetchFromDB()

        // then
        output.checkInvocations([.didFail(expectedError)])
    }

    func testFetchFromNetwork() {
        // given
        let expectedThing = Thing(value: 42, message: "Answer")

        // when
        service.fetchFromNetwork()

        // then
        output.checkInvocations([.didReceive(expectedThing)])
    }

    func testFetchAndDoSomething() {
        // given
        let expectedThing = Thing(value: 42, message: "Answer")

        // when
        service.fetchAndDoSomething()

        // then
        output.checkInvocations([.didReceive(expectedThing),
        .didSomething])
    }
}
```

### Equitability
 `FakeEquatableWrapper` can be used in case of data structure is not `Equatable` but needs to be tested with `XCTAssertEqual` inside unit test:

```swift
func testIsEqual() {
    let firstThing = Thing(value: 42, message: "Answer")
    let secondThing = Thing(value: 42, message: "Question")
    let wrappedFirstThing = FakeEquatableWrapper(firstThing)
    let wrappedSecondThing = FakeEquatableWrapper(secondThing)

    XCTAssertEqual(wrappedFirstThing, wrappedSecondThing)
}
```

### Tips and tricks
To react on invocation changes one can do something like this inside mock:
```swift
var invocations: [Invocation] = [] {
    didSet {
        invocationsDidChange?(self)
    }
}
var invocationsDidChange: ((MockClass) -> Void)?
```

and add callback inside unit test:
```swift
output.invocationsDidChange = {
    //
}
```
