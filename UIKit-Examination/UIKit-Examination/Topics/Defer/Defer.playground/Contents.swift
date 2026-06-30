import Foundation

// MARK: - Swift `defer` Playground Documentation
//
// Swift's defer keyword lets us set up some work to be performed when the current scope exits.

// Current scope can be:
// - a function
// - a loop iteration
// - a do block
// - a throwing function
//
// Important rules:
// 1. `defer` does NOT run immediately.
// 2. It runs when the current scope is about to exit.
// 3. It runs even if the scope exits early using `return`.
// 4. It runs even if an error is thrown.
// 5. Multiple `defer` blocks run in reverse order.
// 6. You cannot use `return`, `break`, or `continue` inside a `defer` block.

// For example, you might want to make sure that some temporary resources are cleaned up once a method exits, and defer will make sure that happens no matter how that exit happens.

// MARK: - Helper

func section(_ title: String) {
    print("\n========== \(title) ==========")
}


// MARK: - 1. Basic defer Example

func basicDeferExample() {
    section("1. Basic defer")

    print("Step 1")

    defer {
        print("Step 3 - defer runs at the end of this function")
    }

    print("Step 2")
}

basicDeferExample()

// Expected output:
// Step 1
// Step 2
// Step 3 - defer runs at the end of this function


// MARK: - 2. defer inside a do block

func deferInsideDoBlock() {
    section("2. defer inside do block")

    print("Before do block")

    do {
        print("Inside do block - Step 1")

        defer {
            print("Inside do block - deferred cleanup")
        }

        print("Inside do block - Step 2")
    }

    print("After do block")
}

deferInsideDoBlock()

// Expected output:
// Before do block
// Inside do block - Step 1
// Inside do block - Step 2
// Inside do block - deferred cleanup
// After do block


// MARK: - 3. Multiple defer blocks

func multipleDeferExample() {
    section("3. Multiple defer blocks")

    print("Start")

    defer {
        print("First defer")
    }

    defer {
        print("Second defer")
    }

    defer {
        print("Third defer")
    }

    print("End")
}

multipleDeferExample()

// Important:
// Multiple defer blocks run in reverse order.
//
// Expected output:
// Start
// End
// Third defer
// Second defer
// First defer


// MARK: - 4. defer inside loop

func deferInsideLoopExample() {
    section("4. defer inside loop")

    for i in 1...3 {
        print("In \(i)")

        defer {
            print("Deferred \(i)")
        }

        print("Out \(i)")
    }
}

deferInsideLoopExample()

// Important:
// In a loop, defer runs at the end of EACH iteration.
//
// Expected output:
// In 1
// Out 1
// Deferred 1
// In 2
// Out 2
// Deferred 2
// In 3
// Out 3
// Deferred 3


// MARK: - 5. defer with early return

func loginUser(username: String?) {
    section("5. defer with early return")

    print("Start login process")

    defer {
        print("Cleanup: hide loading indicator")
    }

    guard let username, !username.isEmpty else {
        print("Invalid username")
        return
    }

    print("Login successful for \(username)")
}

loginUser(username: nil)
loginUser(username: "Sifat")

// Important:
// Even if `return` happens early, `defer` still runs before leaving the function.


// MARK: - 6. defer with throwing function

enum FileError: Error {
    case fileNotFound
}

func readFile(name: String) throws {
    section("6. defer with throw")

    print("Opening file")

    defer {
        print("Closing file")
    }

    if name.isEmpty {
        print("File name is empty")
        throw FileError.fileNotFound
    }

    print("Reading file: \(name)")
}

do {
    try readFile(name: "")
} catch {
    print("Caught error: \(error)")
}

// Important:
// Even when an error is thrown, defer runs before the function exits.


// MARK: - 7. Practical example: loading state

final class ViewModel {
    var isLoading = false

    func fetchData(success: Bool) {
        section("7. Practical loading state example")

        isLoading = true
        print("Loading started:", isLoading)

        defer {
            isLoading = false
            print("Loading stopped:", isLoading)
        }

        guard success else {
            print("API failed")
            return
        }

        print("API success")
    }
}

let viewModel = ViewModel()
viewModel.fetchData(success: false)
viewModel.fetchData(success: true)


// MARK: - 8. Practical example: temporary resource cleanup

func temporaryResourceExample() {
    section("8. Temporary resource cleanup")

    print("Create temporary resource")

    defer {
        print("Remove temporary resource")
    }

    print("Use temporary resource")
}

temporaryResourceExample()

// Real-life use cases:
// - close file
// - unlock lock
// - stop loading
// - reset temporary state
// - call completion handler
// - cleanup resource before leaving scope


// MARK: - 9. What is NOT allowed inside defer?

func notAllowedInsideDefer() {
    section("9. Not allowed inside defer")

    defer {
        print("This is okay")

        // Not allowed:
        // return
        // break
        // continue
    }

    print("Function body")
}

notAllowedInsideDefer()


// MARK: - Interview Friendly Answer
//
// `defer` is a Swift statement that schedules a block of code to run
// just before the current scope exits. It is mainly used for cleanup work,
// such as stopping a loader, closing a file, unlocking a lock, or resetting state.
// It runs even if the function returns early or throws an error.
// If there are multiple defer blocks, they execute in reverse order.
